To achieve this, you need to create a Python script that performs these actions and sets up a cron job to run the script daily. Below is an example of such a script:

1. **Python Script for Backup:**

```python
import os
import subprocess
import datetime

# Define the paths and database credentials
wordpress_path = '/var/www/html/wordpress'
backup_path = '/var/backups/wordpress'
db_name = 'wordpress_db'
db_user = 'db_user'
db_password = 'db_password'
db_host = 'localhost'

# Create the backup directory if it doesn't exist
if not os.path.exists(backup_path):
    os.makedirs(backup_path)

# Get the current date and time for the backup file names
now = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')

# Backup the WordPress site files
site_backup_file = os.path.join(backup_path, f'wordpress_files_{now}.tar.gz')
subprocess.run(['tar', '-czf', site_backup_file, wordpress_path])

# Backup the WordPress database
db_backup_file = os.path.join(backup_path, f'wordpress_db_{now}.sql')
subprocess.run(['mysqldump', '-h', db_host, '-u', db_user, f'-p{db_password}', db_name, '-r', db_backup_file])

# Create a compressed file with all the backups
final_backup_file = os.path.join(backup_path, f'wordpress_backup_{now}.tar.gz')
subprocess.run(['tar', '-czf', final_backup_file, site_backup_file, db_backup_file])

# Cleanup individual backup files
os.remove(site_backup_file)
os.remove(db_backup_file)

print(f'Backup completed successfully. Backup file: {final_backup_file}')
```

2. **Set up Cron Job:**

To set up a cron job to run this script daily, you can create a bash script to add a cron job, or manually add it to the crontab.

**Bash Script to Add Cron Job:**

```bash
#!/bin/bash

# Path to the Python script
script_path="/path/to/your/backup_script.py"

# Add the cron job to the crontab
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/bin/python3 $script_path") | crontab -
```

Make the bash script executable:

```bash
chmod +x add_cron_job.sh
```

Then run the bash script to add the cron job:

```bash
./add_cron_job.sh
```

**Manually Add Cron Job:**

1. Open the crontab editor:
   ```bash
   crontab -e
   ```
2. Add the following line to run the backup script every day at 2 AM:
   ```bash
   0 2 * * * /usr/bin/python3 /path/to/your/backup_script.py
   ```

Replace `/path/to/your/backup_script.py` with the actual path to your Python backup script.

Make sure the Python script has execute permissions:

```bash
chmod +x /path/to/your/backup_script.py
```

This setup will ensure that your WordPress site files and database are backed up daily, and the backups are compressed and stored in the specified directory.
