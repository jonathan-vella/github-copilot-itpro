FROM php:8.2-apache

# Install PHP extensions
RUN apt-get update && \
    apt-get install -y \
        libcurl4-openssl-dev \
        libssl-dev \
        zip \
        unzip && \
    docker-php-ext-install curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Enable mod_rewrite for Apache
RUN a2enmod rewrite

# Configure Apache to allow .htaccess files
COPY apache-config.conf /etc/apache2/conf-available/custom-apache-config.conf
RUN a2enconf custom-apache-config

# Set the working directory
WORKDIR /var/www/html

# Copy PHP files
COPY . .

# Change ownership of web files
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
