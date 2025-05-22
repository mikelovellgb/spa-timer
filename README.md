# Spa Timer

This is a spa timer React application with reset hooks.

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

---

