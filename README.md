# AIRGO MVP — setup and deployment

This is a mobile-responsive, installable PWA starter for Chhatrapati Sambhajinagar. It includes nearby approved business listings, GPS, map markers, service filters, open-hours filter, ratings display, business-owner sign-up/submission, and an admin approval/add-listing screen.

## 1. What you need
- A Supabase account: https://supabase.com
- A GitHub account: https://github.com
- A Vercel account: https://vercel.com
- A computer is easiest for initial setup. You can manage the deployed site from Android afterwards.

## 2. Create the database
1. Create a new Supabase project. Save its database password securely.
2. Open **SQL Editor** in the Supabase dashboard.
3. Open `supabase-schema.sql` from this project, copy all SQL, paste it into SQL Editor and click **Run**.
4. Go to **Project Settings → API** (or Data API / API Keys depending on dashboard version).
5. Copy the Project URL and the publishable/anon public key.

## 3. Configure the website
1. Open `config.js`.
2. Replace `https://YOUR-PROJECT.supabase.co` with your Supabase Project URL.
3. Replace `YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY` with the public publishable/anon key.
4. Do NOT use the `service_role` or secret key in `config.js`.
5. In Supabase → Authentication → URL Configuration, add your deployed website URL to Site URL and Redirect URLs. During local testing add `http://localhost:8000/**`.

## 4. Make yourself admin
1. Run the website and create a business-owner account using the email you want to use as admin.
2. Confirm your email if Supabase email confirmation is enabled.
3. In Supabase SQL Editor run this, replacing the email:
   `update public.profiles set role='admin' where email='you@example.com';`
4. Sign out and sign in again on AIRGO. Open **Business / Admin**. Your admin panel should appear.
5. Do not give admin access to other accounts unless you intend to.

## 5. Add your first businesses
- Admin can add listings manually. Latitude and longitude are required.
- Find coordinates using a map: right-click/long-press the exact location in Google Maps and copy the coordinates.
- Business owners can create an account and submit a listing request. Admin reviews and approves it.
- Public visitors only see records with status `approved`.

## 6. Test locally
This is a static site. From the project folder, run a local static server:
- Python: `python -m http.server 8000`
- Open `http://localhost:8000`
- Geolocation and PWA install require localhost or HTTPS.

## 7. Deploy on Vercel
1. Create a GitHub repository named `airgo-mvp`.
2. Upload all project files and folders to the repository (keep `index.html` at the repository root).
3. In Vercel choose **Add New → Project**, import the repository.
4. Framework preset: **Other**. Build command: leave empty. Output directory: `.` (or root, depending on Vercel UI). Deploy.
5. Add the deployed domain to Supabase Authentication URL Configuration.
6. Open the HTTPS URL on Android Chrome. Use **Install app** when prompted or Chrome menu → Add to Home screen.

Alternative: Netlify Drop can deploy the folder as a static site: https://app.netlify.com/drop

## 8. Important MVP limitations / launch checklist
- The initial owner request form does not yet capture GPS coordinates. Admin can add coordinates when approving by manually creating the verified listing. Extend this workflow before scaling.
- Open-now uses the visitor device's local time and same-day opening hours; overnight schedules need additional validation.
- Ratings are displayed but the rating submission interface and aggregate calculation are not yet included. Add verified/abuse-resistant reviews before public launch.
- Public reviews currently permit anonymous inserts at database level in the SQL. Add CAPTCHA, rate limits, moderation, and abuse prevention before promoting reviews.
- The public map depends on OpenStreetMap tile availability and internet connectivity. Follow the tile usage policy; for significant traffic use a suitable tile provider.
- Supabase free-tier limits, Vercel limits, and map tile terms may change. Check current terms before commercial launch.
- The MVP currently uses map search and exact GPS distance calculations in the browser, not a full geographic database query. This is suitable for a small pilot dataset; use PostGIS/geospatial pagination as the directory grows.
- Keep the admin account secure. Enable strong password and MFA where available. Never share Supabase secret/service-role keys.

## 9. Suggested pilot
Start by verifying and adding 30–50 real locations across Chhatrapati Sambhajinagar. Check coordinates, phone numbers, services, opening hours and whether air filling is actually offered. Do not publish guessed or unverified businesses.
