import os
import sys
import requests
import subprocess
import time
from PyQt6.QtGui import QIcon
from PyQt6.QtWidgets import QApplication, QMessageBox
from setupconfig import ConfigSetupApp
from PrintConfig import PrintConfig
import configparser


# Initialize QApplication
app = QApplication([])

# Get the base directory (for PyInstaller)
base_dir = getattr(sys, "_MEIPASS", os.path.abspath("."))

# Set the path to the application icon (replace 'logo.ico' with your actual icon file)
app_icon_path = os.path.join(base_dir, "logo.ico")

# Set the application icon
app.setWindowIcon(QIcon(app_icon_path))

# Define the path to the local manifest file
local_manifest_path = os.path.join(base_dir, "manifest.ini")

# Define the URL of the remote manifest file
remote_manifest_url = "https://printasyougo.co.uk/update-manifest/manifest.ini"

# Define the path to the config file
config_file_path = os.path.join(os.path.dirname(sys.argv[0]), "config.ini")

# Function to check for updates and perform the update
def version_tuple(version_str):
    """Converts a version string to a tuple of integers."""
    return tuple(map(int, version_str.split('.')))

def read_local_version():
    """Reads the version from the local manifest.ini file."""
    config = configparser.ConfigParser()
    config.read(local_manifest_path)
    version = config.get('Application', 'Version')
    return version_tuple(version)

def check_and_update():
    try:
        response = requests.get(remote_manifest_url)
        response.raise_for_status()
        remote_manifest = response.text
        print(f"Downloaded manifest file: {remote_manifest}")
    except requests.RequestException as e:
        print(f"Failed to fetch the update manifest: {str(e)}")
        QMessageBox.critical(None, "Error", f"Failed to fetch the update manifest: {str(e)}")
        return
    except requests.HTTPError as e:
        print(f"HTTP error: {str(e)}")
        QMessageBox.critical(None, "Error", f"HTTP error: {str(e)}")
        return

    local_version = read_local_version()
    remote_version, update_url, changelog = remote_manifest.strip().split("\n", 2)
    remote_version = version_tuple(remote_version)
    
    # Convert version tuples to strings for display
    local_version_str = ".".join(map(str, local_version))
    remote_version_str = ".".join(map(str, remote_version))
    
    print(f"Current Version: {local_version_str}, New Version: {remote_version_str}")

    if local_version < remote_version:
        # Parse changelog entries
        changelog_entries = changelog.split('\n')[1:]  # Exclude the first line which contains the version
        changelog_since_last_version = []

        # Find changelog entries since the local version
        for entry in changelog_entries:
            version_entry = entry.split('-')[0].strip()
            version_entry_tuple = version_tuple(version_entry)
            if version_entry_tuple > local_version:
                changelog_since_last_version.append(entry)

        if changelog_since_last_version:
            reply = QMessageBox()
            reply.setWindowTitle("Update Available")
            reply.setText(f"An update is available to the Print As You Go Client\n\nCurrent Version: {local_version_str}\nNew Version: {remote_version_str}\n\nChanges since version {local_version_str}:\n{chr(10).join(changelog_since_last_version)}\n\nDo you want to update?")
            reply.setStandardButtons(QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)

            x = reply.exec()

            if x == QMessageBox.StandardButton.Yes:
                try:
                    updated_exe = requests.get(update_url).content
                    print("Downloaded updated executable")
                except requests.RequestException as e:
                    print(f"Failed to download the update: {str(e)}")
                    QMessageBox.critical(None, "Error", f"Failed to download the update: {str(e)}")
                    return

                # Save the updated executable as payg-update.exe
                update_exe_path = os.path.join(os.path.dirname(sys.argv[0]), "payg-update.exe")
                with open(update_exe_path, "wb") as exe_file:
                    exe_file.write(updated_exe)

                # Create a batch file to replace payg.exe with payg-update.exe and add a 3-second delay
                bat_content = (
                    f'timeout /nobreak /t 3 >nul\n'
                    f'copy /y "{update_exe_path}" "{os.path.join(os.path.dirname(sys.argv[0]), "payg.exe")}"\n'
                    f'del /q "{update_exe_path}"\n'
                    f'start /B "" "{os.path.join(os.path.dirname(sys.argv[0]), "payg.exe")}"'
                )
                bat_file_path = os.path.join(os.path.dirname(sys.argv[0]), "update.bat")
                with open(bat_file_path, "w") as bat_file:
                    bat_file.write(bat_content)

                print("Update successful. Exiting the application.")
                
                # Exit the application
                subprocess.Popen([bat_file_path], shell=True, close_fds=True)
                sys.exit()
            else:
                print("User chose not to update. Continuing with the existing version.")
        else:
            print("No new changelog entries since the current version.")
    else:
        print("Local version is up-to-date. No need to update.")

def update_config_version():
    try:
        config = configparser.ConfigParser()
        config.read(local_manifest_path)

        # Use the correct section when reading the version
        version_from_manifest = config.get("Application", "Version", fallback="")
        print(f"Version from Manifest: {version_from_manifest}")

        if os.path.exists(config_file_path):
            config = configparser.ConfigParser()
            config.read(config_file_path)

            if version_from_manifest:
                print("Updating 'version' in config.ini.")
                config.set("Settings", "Version", version_from_manifest)
                with open(config_file_path, "w") as config_file:
                    config.write(config_file)
                print("Update successful.")
            else:
                print("Version from manifest.ini is empty. Not updating 'version' in config.ini.")
        else:
            print("config.ini does not exist.")

    except Exception as e:
        print(f"Error updating config version: {e}")

# Check if the config file exists
if os.path.exists(config_file_path):
    print("config.ini exists. Proceeding to update check.")
    check_and_update()
else:
    print("config.ini does not exist. Launching Configuration Setup.")
    # Launch the Configuration Setup
    config_setup_app = ConfigSetupApp()
    config_setup_app.show()
    app.exec()

# Finally, launch the Print Configuration
update_config_version()
print("Launching Print Configuration.")
window = PrintConfig()
window.show()
app.exec()
