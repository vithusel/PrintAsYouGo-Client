import os
import hashlib
import shutil
import sys
import datetime
import configparser
from PyQt6.QtWidgets import QApplication, QWidget, QLabel, QComboBox, QLineEdit, QPushButton, QFileDialog, QMessageBox, QCheckBox, QVBoxLayout, QDateTimeEdit
from PyQt6.QtGui import QIcon 

class PrintConfig(QWidget):
    def __init__(self):
        super(PrintConfig, self).__init__()

        # Define the path to the config file
        config_file_path = os.path.join(os.path.dirname(sys.argv[0]), "config.ini")

        if os.path.exists(config_file_path):
            self.config_file = configparser.ConfigParser()
            self.config_file.read(config_file_path)

            # Set the application icon using an absolute path
            base_dir = getattr(sys, "_MEIPASS", os.path.abspath("."))
            icon_path = os.path.join(base_dir, "logo.ico")
            self.setWindowIcon(QIcon(icon_path))
            # Create the Print Configuration GUI
            self.init_ui()
        else:
            QMessageBox.critical(self, "Error", "Config file not found.")
            sys.exit(1)

    def init_ui(self):
        self.setWindowTitle("Print Configuration")

        # File upload button for PDFs
        self.pdf_file_input = QLineEdit(self)
        self.pdf_file_input.setPlaceholderText("Upload PDF File")
        self.browse_pdf_button = QPushButton("Browse", self)
        self.browse_pdf_button.clicked.connect(self.browse_file)

        # Print options dropdown for Page Size (A4 or A3)
        self.page_size_combo = QComboBox(self)
        self.page_size_combo.addItems(["A4", "A3"])

        # Print options dropdown for Orientation (Portrait or Landscape)
        self.orientation_combo = QComboBox(self)
        self.orientation_combo.addItems(["Portrait", "Landscape"])

        # Dropdown for Color (Color or Black and White)
        self.color_combo = QComboBox(self)
        self.color_combo.addItems(["Color", "Black and White"])

        # Checkbox for Delay Print
        self.delay_print_var = QCheckBox("Delay Print", self)
        self.delay_print_datetime_edit = QDateTimeEdit(self)
        self.delay_print_datetime_edit.setDateTime(datetime.datetime.now())
        self.delay_print_datetime_edit.setDisabled(True)
        self.delay_print_var.stateChanged.connect(lambda: self.toggle_delay_print())

        # Checkbox for Flatten
        self.flatten_var = QCheckBox("Flatten", self)

        # Checkbox for Print Location
        self.print_location_combo = QComboBox(self)
        self.print_location_combo.addItems(self.get_subfolders())
        
        # Submit button
        self.submit_button = QPushButton("Submit", self)
        self.submit_button.clicked.connect(self.handle_pdf_printing)

        # About button
        self.about_button = QPushButton("About", self)
        self.about_button.clicked.connect(self.show_about_details)

        # Layout setup
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Upload PDF File:"))
        layout.addWidget(self.pdf_file_input)
        layout.addWidget(self.browse_pdf_button)
        layout.addWidget(QLabel("Page Size:"))
        layout.addWidget(self.page_size_combo)
        layout.addWidget(QLabel("Orientation:"))
        layout.addWidget(self.orientation_combo)
        layout.addWidget(QLabel("Color:"))
        layout.addWidget(self.color_combo)
        layout.addWidget(self.delay_print_var)
        layout.addWidget(self.delay_print_datetime_edit)
        layout.addWidget(self.flatten_var)
        layout.addWidget(QLabel("Print Location:"))
        layout.addWidget(self.print_location_combo)
        layout.addWidget(self.submit_button)
        layout.addWidget(self.about_button)

        self.setLayout(layout)
        self.setFixedWidth(500)

    def browse_file(self):
        file_path, _ = QFileDialog.getOpenFileName(self, "Select a PDF file", "/", "PDF Files (*.pdf)")
        if file_path:
            self.pdf_file_input.setText(file_path)

    def toggle_delay_print(self):
        self.delay_print_datetime_edit.setDisabled(not self.delay_print_var.isChecked())

    def get_subfolders(self):
        location = self.config_file.get("Settings", "Location", fallback="")
        subfolders = [f for f in os.listdir(location) if os.path.isdir(os.path.join(location, f))]
        return subfolders

    def show_about_details(self):
        # Read values from manifest.ini
        config = configparser.ConfigParser()
        config.read(os.path.join(getattr(sys, "_MEIPASS", os.path.abspath(".")), "manifest.ini"))

        app_name = config.get("Application", "Name", fallback="Print As You Go")
        version = config.get("Application", "Version", fallback="Error Manifest Missing")
        developer = config.get("Application", "Developer", fallback="Vithurshan Selvarajah")

        about_message = (
            f"Application Name: {app_name}\n"
            f"Version: {version}\n"
            f"Developer: {developer}\n"
        )

        QMessageBox.information(self, "About", about_message)

    def handle_pdf_printing(self):
        pdf_file_path = self.pdf_file_input.text()
        selected_location = self.print_location_combo.currentText()
        page_size = self.page_size_combo.currentText()
        orientation = self.orientation_combo.currentText()
        color = 1 if self.color_combo.currentText() == "Color" else 0
        delay_print = self.delay_print_var.isChecked()
        delay_print_time = self.delay_print_datetime_edit.dateTime().toString("yyyy-MM-dd HH:mm:ss")
        flatten = 1 if self.flatten_var.isChecked() else 0

        # Read values from manifest.ini
        config = configparser.ConfigParser()
        config.read(os.path.join(getattr(sys, "_MEIPASS", os.path.abspath(".")), "manifest.ini"))
        version = config.get("Application", "Version", fallback="Error Manifest Missing")

        if pdf_file_path and selected_location:
            pdf_file_name = os.path.basename(pdf_file_path)
            location = self.config_file.get("Settings", "Location", fallback="")
            destination_path = os.path.join(location, selected_location)
            printing_folder = os.path.join(destination_path, "Printing")
            os.makedirs(printing_folder, exist_ok=True)

            destination_file_path = os.path.join(printing_folder, pdf_file_name.replace(' ', '_'))

            if os.path.exists(destination_file_path):
                overwrite = QMessageBox.question(self, "File Exists", "A file with the same name already exists in the 'Printing' folder. Do you want to overwrite it?", QMessageBox.Yes | QMessageBox.No)
                if overwrite == QMessageBox.No:
                    return

                archive_folder = os.path.join(printing_folder, "Archive")
                os.makedirs(archive_folder, exist_ok=True)

                timestamp = f"{datetime.datetime.now():%Y-%m-%d-%H-%M-%S}"
                archive_pdf_file_path = os.path.join(archive_folder, f"{pdf_file_name.replace(' ', '_')}-{timestamp}.pdf")
                archive_ini_file_path = os.path.join(archive_folder, f"{pdf_file_name.replace(' ', '_')}-{timestamp}.ini")

                existing_ini_path = destination_file_path + ".ini"
                if os.path.exists(existing_ini_path):
                    shutil.copy(existing_ini_path, archive_ini_file_path)

                    config = configparser.ConfigParser()
                    config.read(archive_ini_file_path)
                    config["Intervention"] = {"UserName": os.getlogin(), "MachineName": os.uname().nodename}
                    with open(archive_ini_file_path, "w") as configfile:
                        config.write(configfile)

                try:
                    shutil.move(destination_file_path, archive_pdf_file_path)
                    QMessageBox.information(self, "Success", "File overwritten and moved to the 'Archive' folder with timestamp in the filename.")
                except Exception as e:
                    QMessageBox.critical(self, "Error", f"Failed to move the existing file to the 'Archive' folder: {e}")
                    return

            try:
                shutil.copy(pdf_file_path, destination_file_path)
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to copy the PDF file to the 'Printing' folder: {e}")
                return

            md5_hash = hashlib.md5()
            with open(destination_file_path, "rb") as pdf_file:
                for chunk in iter(lambda: pdf_file.read(4096), b""):
                    md5_hash.update(chunk)
            md5_hash = md5_hash.hexdigest()

            config_file_path = destination_file_path + ".ini"
            with open(config_file_path, "w") as config_file:
                config = configparser.ConfigParser()
                config["PrintSettings"] = {
                    "PageSize": page_size,
                    "Orientation": orientation,
                    "MD5Hash": md5_hash,
                    "FileName": pdf_file_name,
                    "SubmissionDateTime": datetime.datetime.now().strftime("%Y/%m/%d %H:%M:%S"),
                    "Color": color,
                    "Flatten": flatten,
                    "DelayPrintTime": delay_print_time if delay_print else "0",
                    "Version": version
                }
                config["Submitter"] = {
                    "FullName": self.config_file.get("Settings", "FullName", fallback=""),
                    "Company": self.config_file.get("Settings", "Company", fallback=""),
                    "EmailAddress": self.config_file.get("Settings", "EmailAddress", fallback=""),
                    "FileSystem": self.config_file.get("Settings", "FileSystem", fallback="")
                }
                config.write(config_file)

            QMessageBox.information(self, "Success", "PDF file copied to the 'Printing' folder, settings saved, and MD5 hash included in the INI.")
        else:
            QMessageBox.critical(self, "Error", "Please select a PDF file and a print location.")

if __name__ == "__main__":
    app = QApplication([])
    window = PrintConfig()
    window.show()
    app.exec()