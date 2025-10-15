#!/bin/bash
# === Backup automático de WordPress ===
# Autor: Alex Winter

# Configuración
BACKUP_DIR="/home/debian/backups"
WP_DIR="/var/www/html/wordpress"
DB_NAME="wordpress_db"
DB_USER="wordpress_user"
DB_PASS="wordpressSuperSecurePassword"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Crear carpeta de respaldo si no existe
mkdir -p "$BACKUP_DIR/files"
mkdir -p "$BACKUP_DIR/db"

# 1️⃣ Copia de archivos de WordPress
echo "→ Realizando copia de archivos..."
tar -czf "$BACKUP_DIR/files/wordpress_files_$DATE.tar.gz" "$WP_DIR"

# 2️⃣ Copia de base de datos
echo "→ Realizando copia de base de datos..."
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_DIR/db/wordpress_db_$DATE.sql"

# 3️⃣ Crear paquete combinado
echo "→ Generando paquete comprimido final..."
tar -czf "$BACKUP_DIR/wordpress_backup_$DATE.tar.gz" -C "$BACKUP_DIR" files db

# 4️⃣ Eliminar backups antiguos (mantener solo los últimos 7)
find "$BACKUP_DIR" -type f -mtime +7 -delete

echo "✅ Respaldo completado correctamente: $BACKUP_DIR/wordpress_backup_$DATE.tar.gz"
# Mantener solo las 3 copias más recientes
cd /home/debian/backups
ls -tp wordpress_backup_*.tar.gz | grep -v '/$' | tail -n +4 | xargs -I {} rm -- {}
LOG_FILE="/home/debian/backup.log"
if [ -f "$LOG_FILE" ]; then
    tail -n 100 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi
