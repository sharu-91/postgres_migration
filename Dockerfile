# Dockerfile for Phoenix
# Use the latest Phoenix image from Arize
FROM arizephoenix/phoenix:latest

# Expose necessary ports
EXPOSE 6006 4317 9090

# Using embedded SQLite database by default
# No additional environment variables needed for SQLite

# Set restart policy - container will restart automatically on failure or system reboot
# CMD ["phoenix"]

# Health check to verify the application is running correctly
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD curl -f http://localhost:6006 || exit 1
