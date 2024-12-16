"""Process user data file."""

# Third-Party Libraries
import boto3
from jinja2 import Template

ssm = boto3.client("ssm")

# Retrieve Windows Administrator password from AWS SSM
password = ssm.get_parameter(
    Name="/windows/server/administrator/password", WithDecryption=True
)["Parameter"]["Value"]

user_data_file_location = "./winrm_bootstrap.txt"
with open(user_data_file_location) as user_data_file:
    # Process the user data file with the Windows Administrator password
    Template(user_data_file.read()).stream(password=password).dump(
        user_data_file_location
    )

# This password is masked from logging when run via GH Actions.
# But beware if this script is running elsewhere.
print(f"::add-mask::{password}")
print(f"::set-output name=pass::{password}")
