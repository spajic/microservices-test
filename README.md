# Микросервис для расчёта стоимости поездки

## Usage

```bash
git clone ...
RIDE_SERVICE_PORT=9009 GOOGLE_MAPS_API_KEY=secret docker-compose up
curl 'http://localhost:9009/ride_price?from=54.691662,37.503621&to=55.809289,37.582365''
```

## Performance

```bash
ab -c 20 -n 100 'http://localhost:9009/ride_price?from=54.691662,37.503621&to=55.809289,37.582365'
```

Сервис обрабатывает 300 запросов, поступающих в 10 параллельных потоков за 5 секунд.

Это ~3600rpm.

## Tradeoffs

