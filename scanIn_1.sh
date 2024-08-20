#!/bin/bash

DIRECTORY="quanta"
declare -a KEYWORDS=("Shuvi" "Mahin" "home")

DB_HOST="localhost"
DB_USER="root"
DB_pass="new_password"
DB_NAME="scanner"
TABLE_NAME="scan_results"
echo "Connecting to MySQL with user: $DB_USER, db: $DB_NAME"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
EOF

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" <<EOF
CREATE TABLE IF NOT EXISTS $TABLE_NAME (
    id INT AUTO_INCREMENT PRIMARY KEY,
    file_path VARCHAR(255),
    file_type VARCHAR(50),
    status VARCHAR(50),
    inappropriate_content TEXT,
    time DATETIME,
    line TEXT
);
EOF

Upgrade before August 14th!get_file_creation_time(){
    local file=$1
    stat -c %Y "$file"
}

insert_into_database(){
    local file=$1
    local file_type=$2
    local status=$3
    local keywords=$4
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    local lines=$5

    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" <<EOF
    INSERT INTO $TABLE_NAME (file_path, file_type, status, inappropriate_content, time, line)
    VALUES ('$file', '$file_type', '$status', '$keywords', '$timestamp', '$lines');
EOF
}

scan_text_file(){
    local file=$1
    local inappropriate_content=0
    local found_keywords=()
    local found_lines=()

    for keyword in "${KEYWORDS[@]}"; do
        if grep -qi "$keyword" "$file"; then
            found_lines+=($(grep -ni "$keyword" "$file"))
            found_keywords+=("$keyword")
            inappropriate_content=1
        fi
    done

    if [ $inappropriate_content -eq 1 ]; then
        insert_into_database "$file" "text" "Inappropriate" "${found_keywords[*]}" "${found_lines[*]}"
    else
        insert_into_database "$file" "text" "OK" "" ""
    fi
}

while true; do
    find "$DIRECTORY" -type f | while read -r file; do
        extension="${file##*.}"

        case "$extension" in
            txt|java|php|html|js|ts|jsp|srt)
                scan_text_file "$file"
                ;;
            png|jpg|jpeg|svg|gif|mp3|mp4)
                insert_into_database "$file" "media" "OK" "" ""
                ;;
            *)
                insert_into_database "$file" "unknown" "OK" "" ""
                ;;
        esac
    done

    echo "Scanning completed. Results saved to the database."
    sleep 6h
done

