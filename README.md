# macOS Version Checker and Notifier

This PowerShell script checks for the latest version of macOS on the official Apple support page and notifies users via email if a new version is detected. It keeps track of the versions previously detected and sends an alert only when a new version is available. The script uses a configuration file to store email settings and recipient information.

## Features

- **Automated macOS Version Check**: Fetches the current macOS version information from the official Apple support page.
- **Email Notifications**: Sends an email notification when a new macOS version is detected.
- **Version Tracking**: Maintains a record of the previously detected macOS versions to avoid redundant notifications.
- **Configurable Settings**: Uses a separate `config.json` file for easy configuration of email credentials, SMTP server details, and recipient information.

## Usage

1. **Clone the Repository**:
    ```sh
    git clone https://github.com/collmalpa/macos-version-checker.git
    cd macos-version-checker
    ```

2. **Create and Edit `config.json`**:
    - Create a `config.json` file with the following content:
      ```json
      {
          "wordToSearch": "Sonoma",
          "emailSettings": {
              "username": "your_email@example.com",
              "password": "your_password",
              "smtpServer": "smtp.example.com",
              "port": "25"
          },
          "recipients": [
              "recipient@example.com"
          ]
      }
      ```
    - Fill in your email credentials, SMTP server details, and recipient information.

3. **Run the Script**:
    ```powershell
    .\macos-version-checker.ps1
    ```

4. **Schedule the Script**:
    - It's recommended to add this script to the Windows Task Scheduler to run at regular intervals. This ensures you are promptly notified when a new macOS version is available.
    - To add the script to Task Scheduler:
        1. Open Task Scheduler and create a new task.
        2. Set a trigger to run the script at your desired frequency (e.g., daily or weekly).
        3. In the "Actions" tab, set the action to start a program and enter the path to `powershell.exe`.
        4. Add the argument to run your script:
           ```powershell
           -File "C:\path\to\your\script\macos-version-checker.ps1"
           ```
        5. Save the task.

## Script Details

- **Variables**:
  - `wordToSearch`: The macOS version keyword to search for, configured in `config.json`.
  - `emailSettings`: Email credentials and server details for sending notifications, stored in `config.json`.
  - `recipients`: List of email recipients, specified in `config.json`.
  
- **Function**:
  - `send_email`: Sends an email with the specified subject, body, and email credentials.

- **Operation**:
  - Checks if the `macOSVersions.txt` file exists; if not, it creates it.
  - Reads the old macOS version data from `macOSVersions.txt`.
  - Fetches the current macOS version data from the Apple support page.
  - Compares the old and new macOS version counts.
  - If a new version is detected, constructs the email body and sends a notification.
  - Updates `macOSVersions.txt` and `LastMacOS.txt` with the new data.

## Note

The method of sending notifications via email through SMTP is considered outdated. This script demonstrates how it can be implemented in PowerShell, but for modern applications, other notification methods such as APIs or dedicated email services are recommended.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.
