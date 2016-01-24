# dd-alert-pi-example
An datadog alert example with Raspberry pi

## Usage

```
bundle install --path vendor/bundle
echo 2 > /sys/class/gpio/unexport; \
  sudo DD_API_KEY=XXX DD_APP_KEY=XXX bundle exec ruby ./main.rb; \
  echo 2 > /sys/class/gpio/unexport
```
