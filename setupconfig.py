from PyQt6.QtWidgets import QApplication, QWidget, QLabel, QComboBox, QLineEdit, QPushButton, QFileDialog, QMessageBox, QVBoxLayout, QHBoxLayout, QInputDialog
from PyQt6.QtGui import QIcon
import sys
import os
import configparser

class ConfigSetupApp(QWidget):
    def __init__(self):
        super().__init__()

        self.init_ui()

    def init_ui(self):
        # File System dropdown
        self.file_system_label = QLabel("File System:")
        self.file_system_combo = QComboBox()
        file_system_values = ["NextCloud", "OneDrive", "DropBox", "Egnyte", "Box", "Other"]
        self.file_system_combo.addItems(file_system_values)
        self.file_system_combo.setCurrentText("NextCloud")  # Set a default value
        self.file_system_combo.currentIndexChanged.connect(self.on_combo_change)

        # Location input
        self.location_label = QLabel("Location (Folder):")
        self.location_entry = QLineEdit()
        self.browse_button = QPushButton("Browse")
        self.browse_button.clicked.connect(self.browse_button_clicked)

        # Configuration options
        self.full_name_label = QLabel("Full Name:")
        self.full_name_entry = QLineEdit()

        self.company_label = QLabel("Company:")
        self.company_entry = QLineEdit()

        self.email_label = QLabel("Email Address:")
        self.email_entry = QLineEdit()

        # OK button
        self.ok_button = QPushButton("OK")
        self.ok_button.clicked.connect(self.on_ok_button)

        # Set the application icon using an absolute path
        base_dir = getattr(sys, "_MEIPASS", os.path.abspath("."))
        icon_path = os.path.join(base_dir, "logo.ico")
        self.setWindowIcon(QIcon(icon_path))
        # Layout
        layout = QVBoxLayout()
        layout.addWidget(self.file_system_label)
        layout.addWidget(self.file_system_combo)

        location_layout = QHBoxLayout()
        location_layout.addWidget(self.location_label)
        location_layout.addWidget(self.location_entry)
        location_layout.addWidget(self.browse_button)
        layout.addLayout(location_layout)

        layout.addWidget(self.full_name_label)
        layout.addWidget(self.full_name_entry)

        layout.addWidget(self.company_label)
        layout.addWidget(self.company_entry)

        layout.addWidget(self.email_label)
        layout.addWidget(self.email_entry)

        layout.addWidget(self.ok_button)

        self.setLayout(layout)

        self.setWindowTitle("Configuration Setup")

    def on_combo_change(self):
        # Show the "Other" input box if "Other" is selected
        if self.file_system_combo.currentText() == "Other":
            custom_system, ok_pressed = QInputDialog.getText(self, "Other File System", "Enter a custom file system:")
            if ok_pressed and custom_system:
                # Add the custom system to the dropdown and set it as the current text
                self.file_system_combo.addItem(custom_system)
                self.file_system_combo.setCurrentText(custom_system)

    def browse_button_clicked(self):
        folder_path = QFileDialog.getExistingDirectory(self, "Select a folder", '/')
        if folder_path:
            self.location_entry.setText(folder_path)

    def update_config_file(self):
        # Implement your logic to update the config file with the latest version
        pass

    def on_ok_button(self):
        file_system = self.file_system_combo.currentText()
        location = self.location_entry.text()
        full_name = self.full_name_entry.text()
        company = self.company_entry.text()
        email = self.email_entry.text()

        # Check if all fields have values
        if not all([file_system, location, full_name, company, email]):
            QMessageBox.critical(self, "Error", "Please fill in all fields.")
        else:
            # Check if the folder path exists
            if not os.path.exists(location):
                QMessageBox.critical(self, "Error", "The specified folder does not exist.")
            elif "@" not in email or "." not in email.split("@")[-1]:
                QMessageBox.critical(self, "Error", "Invalid email address format.")
            else:
                # Write the values to the config file
                config = configparser.ConfigParser()
                config.read("config.ini")  # You can customize the path if needed

                config["Settings"] = {
                    "FileSystem": file_system,
                    "Location": location,
                    "FullName": full_name,
                    "Company": company,
                    "EmailAddress": email,
                }

                with open("config.ini", "w") as config_file:
                    config.write(config_file)

                # Update the config file with the latest version
                self.update_config_file()

                # Close the GUI
                self.close()


if __name__ == '__main__':
    app = QApplication([])
    config_setup_app = ConfigSetupApp()
    config_setup_app.show()
    app.exec()