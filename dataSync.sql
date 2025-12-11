import psycopg2

# Connect to the source database
source_conn = psycopg2.connect(
    host='source_host',
    database='source_database',
    user='source_user',
    password='source_password'
)
source_cursor = source_conn.cursor()

# Execute the query
source_query = "SELECT * FROM source_table"
source_cursor.execute(source_query)

# Fetch all results
results = source_cursor.fetchall()

# Connect to the destination database
dest_conn = psycopg2.connect(
    host='destination_host',
    database='destination_database',
    user='destination_user',
    password='destination_password'
)
dest_cursor = dest_conn.cursor()

# Prepare the insert statement
insert_query = "INSERT INTO destination_table (column1, column2) VALUES (%s, %s)"

# Insert each result into the destination table
for row in results:
    dest_cursor.execute(insert_query, (row[0], row[1]))  # Adjust based on your columns

# Commit changes and close connections
dest_conn.commit()

# Close all connections
source_cursor.close()
dest_cursor.close()
source_conn.close()
dest_conn.close()


pip install psycopg2
pip install psycopg2-binary


----------------------------------

import psycopg2
from psycopg2 import sql

# Connect to the source database
source_conn = psycopg2.connect(
    host='source_host',
    database='source_database',
    user='source_user',
    password='source_password'
)
source_cursor = source_conn.cursor()

# Execute the query
source_query = "SELECT * FROM source_table"
source_cursor.execute(source_query)

# Fetch all results
results = source_cursor.fetchall()

# Connect to the destination database
dest_conn = psycopg2.connect(
    host='destination_host',
    database='destination_database',
    user='destination_user',
    password='destination_password'
)
dest_cursor = dest_conn.cursor()

# Prepare the insert statement
insert_query = sql.SQL("INSERT INTO destination_table (column1, column2) VALUES (%s, %s)")

# Batch size
batch_size = 1000
batch = []

# Insert results in batches
for row in results:
    batch.append(row)
    if len(batch) >= batch_size:
        dest_cursor.executemany(insert_query, batch)
        batch = []  # Clear the batch

# Insert any remaining rows in the last batch
if batch:
    dest_cursor.executemany(insert_query, batch)

# Commit changes and close connections
dest_conn.commit()

# Close all connections
source_cursor.close()
dest_cursor.close()
source_conn.close()
dest_conn.close()

---------------------------------------

Step 1: Create the Python Script (data_transfer.py)

import psycopg2
from psycopg2 import sql

def transfer_data():
    # Connect to the source database
    source_conn = psycopg2.connect(
        host='source_host',
        database='source_database',
        user='source_user',
        password='source_password'
    )
    source_cursor = source_conn.cursor()

    # Execute the query
    source_query = "SELECT * FROM source_table"
    source_cursor.execute(source_query)

    # Fetch all results
    results = source_cursor.fetchall()

    # Connect to the destination database
    dest_conn = psycopg2.connect(
        host='destination_host',
        database='destination_database',
        user='destination_user',
        password='destination_password'
    )
    dest_cursor = dest_conn.cursor()

    # Prepare the insert statement
    insert_query = sql.SQL("INSERT INTO destination_table (column1, column2) VALUES (%s, %s)")

    # Batch size
    batch_size = 1000
    batch = []

    # Insert results in batches
    for row in results:
        batch.append(row)
        if len(batch) >= batch_size:
            dest_cursor.executemany(insert_query, batch)
            batch = []  # Clear the batch

    # Insert any remaining rows in the last batch
    if batch:
        dest_cursor.executemany(insert_query, batch)

    # Commit changes and close connections
    dest_conn.commit()

    # Close all connections
    source_cursor.close()
    dest_cursor.close()
    source_conn.close()
    dest_conn.close()

if __name__ == "__main__":
    transfer_data()

Step 2: Make the Script Executable
chmod +x data_transfer.py

Step 3: Schedule the Cron Job
Open the Crontab Editor: Run the following command in your terminal:
crontab -e

Add the Cron Job: Add a line to schedule your script. For example, to run the script every day at 2 AM, you would add:
0 2 * * * /usr/bin/python3 /path/to/your/script/data_transfer.py >> /path/to/your/logfile.log 2>&1

Replace /usr/bin/python3 with the path to your Python interpreter, if necessary.
Replace /path/to/your/script/data_transfer.py with the full path to your script.
>> /path/to/your/logfile.log 2>&1 redirects output and errors to a log file for troubleshooting.

Save and Exit: Save the file and exit the editor. Your cron job is now scheduled.

Step 4: Verify the Cron Job
To verify that your cron job is scheduled correctly, you can run:
crontab -l

--------------------------------
------------------------------------
----------------------------------------
import psycopg2
from psycopg2 import sql

def transfer_data():
    # connect to the source database
    source_conn = psycopg2.connect(
        host  = '192.168.5.88',
        port = 5959,
        database = 'rsup_fatmawati',
        user = 'devit',
        password = 'Inter@1908'
    )
    source_cursor = source_conn.cursor()

    # execute the query
    source_query = "select norec, noregistrasifk, produkfk from pelayananpasien_t where norec = '10d7dd08-f9c3-488e-bb8e-560dd7b6246a'"
    source_cursor.execute(source_query)

    # fetch all result
    result = source_cursor.fetchall()

    # connect to the log database
    log_conn = psycopg2.connect(
        host= '192.168.5.88',
        port = 5959,
        database = 'simrsf',
        user='devit',
        password='Inter@1908'
    )
    log_cursor = log_conn.cursor()

    # connect to the destination database
    dest_conn = psycopg2.connect(
        host= '192.168.5.88',
        port = 5959,
        database = 'simrsf',
        user='devit',
        password='Inter@1908'
    )
    dest_cursor = dest_conn.cursor()

    # prepare the insert statement
    insert_query = sql.SQL("insert into xtest (norec, noregistrasifk, produk) values (%s, %s, %s)")

    #batch size
    batch_size = 1000
    batch = []

    try:
        # insert results in batches
        for row in result:
            batch.append(row)
            if len(batch) >= batch_size:
                dest_cursor.executemany(insert_query, batch)
                batch = [] # clear the batch

        # insert any remaining rows in the last batch
        if batch:
            dest_cursor.executemany(insert_query, batch)
            # commit change
            dest_conn.commit()
            errors = ["success"]
            log_query = sql.SQL("insert into xlog (keterangan, issuccess, created_at) values (%s, true, current_timestamp)")
            log_cursor.execute(log_query, errors)
            log_conn.commit()
    except Exception as e:
        errors = [repr(e)]
        dest_conn.rollback()
        log_query = sql.SQL("insert into xlog (keterangan, issuccess, created_at) values (%s, false, current_timestamp)")
        log_cursor.execute(log_query, errors)
        log_conn.commit()
     
    # close all connection
    source_cursor.close()
    dest_cursor.close()
    log_cursor.close()
    source_conn.close()
    dest_conn.close()
    log_conn.close()

if __name__ == "__main__":
     transfer_data()
