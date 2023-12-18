import tkinter as tk
from tkinter import messagebox

def show_about_details():
    app_name = "Your Application"
    version = "1.0"
    developer = "Your Name"
    project_page = "https://your-project-page.com"

    about_message = (
        f"Application Name: {app_name}\n"
        f"Version: {version}\n"
        f"Developer: {developer}\n"
        f"Project Page: {project_page}"
    )

    messagebox.showinfo("About", about_message)

def update_config_file():
    # Update the config file with the latest version (you need to implement this part)
    # ini_write(config_file, "Settings", "Version", version)
    messagebox.showinfo("Update Config File", "Config file updated with the latest version.")

# Example usage:
# show_about_details()
# update_config_file()
