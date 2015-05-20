Den cesty web
===

Instalace Ruby on Rails
---

Pro správnou funkčnost nainstalujte následující verze:

* Ruby: 1.9.3-p551
* Rails: 3.1.12

Instalace Ruby a Ruby on Rails na systému OS X pomocí Homebrew:

```
$ brew install rbenv
$ if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
$ brew install ruby-build
$ rbenv install 1.9.3-p551
$ rbenv rehash
$ rbenv global 1.9.3-p551
$ gem update --system
$ gem install bundler
$ gem install rails --no-ri --no-rdoc --version 3.1.12
```

Nainstalujte a spusťte aplikaci [Postgres.app](http://postgresapp.com/) a poté pokračujte s konfigurací:

```
$ export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.4/bin/
$ bundle config build.pg -- --with-pg-config=/Applications/Postgres.app/Contents/Versions/9.4/bin/pg_config
$ gem install pg --no-ri --no-rdoc --with-pg-config=/Applications/Postgres.app/Contents/Versions/9.4/bin/pg_config
```

Konfigurace databáze
---

Pomocí příkazu `cd` se přesuňte do adresáře s webem.

```
$ psql
CREATE USER root WITH PASSWORD 'ptolemaios';
CREATE DATABASE den_cesty_development OWNER root;
GRANT ALL PRIVILEGES ON DATABASE den_cesty_development  to root;
```

Spuštění serveru
---

Pomocí příkazu `cd` se přesuňte do adresáře s webem.
```
$ bundle install
$ rake db:setup
$ rails server
```


Administrátorský účet
---

Pokud jste před spuštěním serveru vložili ukázkový obsah do databáze pomocí `$ rake db:setup`, tak máte předvytvořen účet s administrátorskými právy:

* E-mail: `test@test.com`
* Heslo: `password`

Pokud máte zaregistrován účet a chcete administrátorská práva, přidejte svoji e-mailovou adresu v souboru `app/controllers/application_controller.rb` do pole na řádku

```
25: $admin_email = ["user@test.com", "test@test.com"]
```


