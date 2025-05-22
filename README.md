# Spa Timer

A visually striking, API-controlled countdown timer for spas, gyms, or studios. Features a large animated mm:ss timer, custom logo, and room name, with a responsive layout for both standard and tall/narrow (panel) screens. The timer is controlled via simple HTTP API calls (reset, start, stop), and displays a full-screen logo when stopped or at zero. Designed for kiosk or wall display, with robust deployment and update scripts for unattended operation.

## Instructions to Deploy

1. SSH into your device:

   ```sh
   putty <User>@<IP Address> -i <SSH Key>
   ```

2. Clone the repository:

   ```sh
   git clone https://github.com/mikelovellgb/spa-timer
   ```

3. Enter the scripts directory:

   ```sh
   cd spa-timer/scripts/
   ```

4. Make all scripts executable:

   ```sh
   chmod +x *
   ```

5. Run the setup scripts in order:

   ```sh
   ./01_prep_requirements.sh
   ./02_setup_kiosk_on_login.sh
   ./03_build_and_deploy_web.sh
   ```

6. Reboot the device:

   ```sh
   sudo reboot
   ```

---

## Updating the Application

You can update the Spa Timer app at any time by running the following script, which will pull the latest changes from git, rebuild the application, and redeploy the service:

```sh
cd ~/spa-timer/scripts/
./03_build_and_deploy_web.sh
```

This will:
- Pull the latest code from the repository
- Make sure all scripts are executable
- Install any new dependencies
- Rebuild the Next.js app
- Restart the systemd service

It is recommended to run:

```sh
sudo reboot
```

after updating, to ensure all services and kiosk settings are fully applied.

---

## Usage

- Access the timer in your browser:
  - `http://<ip>:3000` — Shows the timer UI

### Timer API

- **Reset the timer:**
  - `http://<ip>:3000/api/timer?reset=<minutes>` — Resets the timer to the specified number of minutes and pauses the timer (timer will not start automatically after reset).
- **Start the timer:**
  - `http://<ip>:3000/api/timer?start` — Starts or resumes the timer if it is paused.
- **Pause/Stop the timer:**
  - `http://<ip>:3000/api/timer?stop` — Pauses the timer (the remaining time is preserved).
- **Get timer state:**
  - `http://<ip>:3000/api/timer` — Returns the current timer state as JSON (remaining seconds and paused status).

Replace `<ip>` with the IP address of your device and `<minutes>` with the number of minutes you want to set.

### UI Behavior

- The timer displays a large, centered countdown in mm:ss format when running.
- When the timer reaches 0 seconds **or** is paused/stopped, the UI displays only the full-screen logo (no timer or room name).
- When the timer is running, the room name and logo are shown to the left of the timer.
- The UI is fully responsive and optimized for both standard and tall/narrow (panel) screens.

