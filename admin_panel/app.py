import os
import time
from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from dotenv import load_dotenv
from supabase import create_client, Client
from functools import wraps
from datetime import datetime, timedelta

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY')
if not app.secret_key:
    raise RuntimeError('SECRET_KEY must be set in .env file')

# Supabase with service_role key (bypasses RLS)
supabase: Client = create_client(
    os.getenv('SUPABASE_URL', ''),
    os.getenv('SUPABASE_SERVICE_KEY', ''),
)

ADMIN_PASSWORD = os.getenv('ADMIN_PASSWORD')
if not ADMIN_PASSWORD:
    raise RuntimeError('ADMIN_PASSWORD must be set in .env file')

# ─── Brute-force protection ───
# Track failed login attempts per IP address
_login_attempts = {}  # {ip: {'count': int, 'last_attempt': float}}
MAX_LOGIN_ATTEMPTS = 5
LOCKOUT_DURATION = 300  # 5 minutes in seconds


def _is_locked_out(ip):
    """Check if the IP is currently locked out due to too many failed attempts."""
    record = _login_attempts.get(ip)
    if record is None:
        return False
    if record['count'] >= MAX_LOGIN_ATTEMPTS:
        elapsed = time.time() - record['last_attempt']
        if elapsed < LOCKOUT_DURATION:
            return True
        else:
            # Lockout expired, reset
            del _login_attempts[ip]
            return False
    return False


def _record_failed_attempt(ip):
    """Record a failed login attempt for the given IP."""
    if ip not in _login_attempts:
        _login_attempts[ip] = {'count': 0, 'last_attempt': 0}
    _login_attempts[ip]['count'] += 1
    _login_attempts[ip]['last_attempt'] = time.time()


def _reset_attempts(ip):
    """Reset failed attempt counter for the given IP after a successful login."""
    _login_attempts.pop(ip, None)


# ─── Auth Decorator ───
def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not session.get('admin_logged_in'):
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated


# ─── Login ───
@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    ip = request.remote_addr

    if _is_locked_out(ip):
        remaining = LOCKOUT_DURATION - int(time.time() - _login_attempts[ip]['last_attempt'])
        error = f'Trop de tentatives échouées. Réessayez dans {remaining // 60} min.'
        return render_template('login.html', error=error)

    if request.method == 'POST':
        password = request.form.get('password', '')
        if password == ADMIN_PASSWORD:
            _reset_attempts(ip)
            session['admin_logged_in'] = True
            return redirect(url_for('dashboard'))
        else:
            _record_failed_attempt(ip)
            attempts_left = MAX_LOGIN_ATTEMPTS - _login_attempts.get(ip, {}).get('count', 0)
            if attempts_left > 0:
                error = f'Mot de passe incorrect. {attempts_left} tentative(s) restante(s).'
            else:
                error = 'Trop de tentatives échouées. Réessayez dans 5 minutes.'
    return render_template('login.html', error=error)


@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))


# ─── Dashboard ───
@app.route('/')
@login_required
def dashboard():
    try:
        # Stats
        rides_today = supabase.table('rides').select('id', count='exact').gte(
            'created_at', datetime.now().strftime('%Y-%m-%d')).execute()
        drivers_online = supabase.table('drivers').select('id', count='exact').eq(
            'is_online', True).execute()
        drivers_pending = supabase.table('drivers').select('id', count='exact').eq(
            'is_verified', False).execute()
        total_clients = supabase.table('profiles').select('id', count='exact').eq(
            'role', 'client').execute()

        # Recent rides
        recent_rides = supabase.table('rides').select(
            '*, client:profiles!rides_client_id_fkey(full_name), driver:profiles!rides_driver_id_fkey(full_name)'
        ).order('created_at', desc=True).limit(10).execute()

        # Revenue today
        completed_today = supabase.table('rides').select('commission').eq(
            'status', 'completed').gte(
            'created_at', datetime.now().strftime('%Y-%m-%d')).execute()
        revenue_today = sum(r['commission'] for r in completed_today.data) if completed_today.data else 0

        return render_template('dashboard.html',
            rides_today=rides_today.count if hasattr(rides_today, 'count') else len(rides_today.data),
            drivers_online=drivers_online.count if hasattr(drivers_online, 'count') else len(drivers_online.data),
            drivers_pending=drivers_pending.count if hasattr(drivers_pending, 'count') else len(drivers_pending.data),
            total_clients=total_clients.count if hasattr(total_clients, 'count') else len(total_clients.data),
            revenue_today=revenue_today,
            recent_rides=recent_rides.data,
            now=datetime.now(),
        )
    except Exception as e:
        return render_template('dashboard.html',
            rides_today=0, drivers_online=0, drivers_pending=0,
            total_clients=0, revenue_today=0, recent_rides=[], error=str(e))


# ─── Drivers Management ───
@app.route('/drivers')
@login_required
def drivers():
    filter_status = request.args.get('status', 'all')
    try:
        query = supabase.table('drivers').select(
            '*, profile:profiles!drivers_id_fkey(full_name, phone)'
        ).order('created_at', desc=True)

        if filter_status == 'pending':
            query = query.eq('is_verified', False)
        elif filter_status == 'verified':
            query = query.eq('is_verified', True)

        result = query.execute()
        return render_template('drivers.html', drivers=result.data, filter_status=filter_status)
    except Exception as e:
        return render_template('drivers.html', drivers=[], filter_status=filter_status, error=str(e))


@app.route('/drivers/<driver_id>/verify', methods=['POST'])
@login_required
def verify_driver(driver_id):
    try:
        supabase.table('drivers').update({'is_verified': True}).eq('id', driver_id).execute()
        # Send notification
        supabase.table('notifications').insert({
            'user_id': driver_id,
            'title': 'Compte vérifié',
            'body': 'Félicitations ! Votre compte chauffeur a été vérifié. Vous pouvez maintenant recevoir des courses.',
            'type': 'verification',
        }).execute()
    except Exception as e:
        app.logger.error(f'Failed to verify driver {driver_id}: {e}')
    return redirect(url_for('drivers'))


@app.route('/drivers/<driver_id>/ban', methods=['POST'])
@login_required
def ban_driver(driver_id):
    try:
        supabase.table('drivers').update({'is_verified': False, 'is_online': False}).eq('id', driver_id).execute()
        supabase.table('notifications').insert({
            'user_id': driver_id,
            'title': 'Compte suspendu',
            'body': 'Votre compte a été suspendu. Contactez le support pour plus d\'informations.',
            'type': 'suspension',
        }).execute()
    except Exception as e:
        app.logger.error(f'Failed to ban driver {driver_id}: {e}')
    return redirect(url_for('drivers'))


@app.route('/drivers/<driver_id>/documents')
@login_required
def driver_documents(driver_id):
    try:
        result = supabase.table('drivers').select(
            '*, profile:profiles!drivers_id_fkey(full_name, phone)'
        ).eq('id', driver_id).single().execute()
        driver = result.data
        # Get signed URLs for documents if they exist
        docs = {}
        for field, url in [
            ('id_card', driver.get('id_card_url')),
            ('license', driver.get('license_url')),
            ('vehicle', driver.get('vehicle_photo_url')),
        ]:
            if url:
                try:
                    # Extract the storage path from the public URL
                    if '/driver-documents/' in url:
                        path = url.split('/driver-documents/', 1)[1]
                        if '?' in path:
                            path = path.split('?', 1)[0]
                    elif '/documents/' in url:
                        path = url.split('/documents/', 1)[1]
                        if '?' in path:
                            path = path.split('?', 1)[0]
                    else:
                        path = url

                    signed = supabase.storage.from_('driver-documents').create_signed_url(path, 3600)
                    docs[field] = signed.get('signedURL', url)
                except Exception:
                    docs[field] = url
            else:
                docs[field] = None
        return render_template('driver_documents.html', driver=driver, docs=docs)
    except Exception as e:
        return render_template('driver_documents.html', driver=None, docs={}, error=str(e))


# ─── Rides Management ───
@app.route('/rides')
@login_required
def rides():
    filter_status = request.args.get('status', 'all')
    try:
        query = supabase.table('rides').select(
            '*, client:profiles!rides_client_id_fkey(full_name, phone), driver:profiles!rides_driver_id_fkey(full_name)'
        ).order('created_at', desc=True).limit(100)

        if filter_status != 'all':
            query = query.eq('status', filter_status)

        result = query.execute()
        return render_template('rides.html', rides=result.data, filter_status=filter_status)
    except Exception as e:
        return render_template('rides.html', rides=[], filter_status=filter_status, error=str(e))


# ─── Clients Management ───
@app.route('/clients')
@login_required
def clients():
    try:
        result = supabase.table('profiles').select('*').eq('role', 'client').order('created_at', desc=True).limit(100).execute()
        return render_template('clients.html', clients=result.data)
    except Exception as e:
        return render_template('clients.html', clients=[], error=str(e))


# ─── Landmarks Management ───
@app.route('/landmarks')
@login_required
def landmarks():
    try:
        result = supabase.table('landmarks').select('*').order('name_fr').execute()
        return render_template('landmarks.html', landmarks=result.data)
    except Exception as e:
        return render_template('landmarks.html', landmarks=[], error=str(e))


@app.route('/landmarks/add', methods=['POST'])
@login_required
def add_landmark():
    try:
        data = {
            'name_fr': request.form.get('name_fr'),
            'name_en': request.form.get('name_en'),
            'category': request.form.get('category', 'autre'),
            'lat': float(request.form.get('lat', 0)),
            'lng': float(request.form.get('lng', 0)),
            'is_popular': request.form.get('is_popular') == 'on',
        }
        supabase.table('landmarks').insert(data).execute()
    except Exception as e:
        app.logger.error(f'Failed to add landmark: {e}')
    return redirect(url_for('landmarks'))


@app.route('/landmarks/<landmark_id>/delete', methods=['POST'])
@login_required
def delete_landmark(landmark_id):
    try:
        supabase.table('landmarks').delete().eq('id', landmark_id).execute()
    except Exception as e:
        app.logger.error(f'Failed to delete landmark {landmark_id}: {e}')
    return redirect(url_for('landmarks'))


# ─── Send Notification ───
@app.route('/notifications/send', methods=['GET', 'POST'])
@login_required
def send_notification():
    if request.method == 'POST':
        try:
            target = request.form.get('target', 'all')
            title = request.form.get('title')
            body = request.form.get('body')

            if target == 'all':
                users = supabase.table('profiles').select('id').execute()
                notifications = [{'user_id': user['id'], 'title': title, 'body': body, 'type': 'admin'} for user in users.data]
                supabase.table('notifications').insert(notifications).execute()
            elif target == 'drivers':
                drivers_list = supabase.table('drivers').select('id').execute()
                notifications = [{'user_id': d['id'], 'title': title, 'body': body, 'type': 'admin'} for d in drivers_list.data]
                supabase.table('notifications').insert(notifications).execute()
            else:
                supabase.table('notifications').insert({
                    'user_id': target,
                    'title': title,
                    'body': body,
                    'type': 'admin',
                }).execute()
        except Exception as e:
            app.logger.error(f'Failed to send notification: {e}')
        return redirect(url_for('send_notification'))
    return render_template('send_notification.html')


if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=int(os.getenv('PORT', 5000)))
