# Microservice app to calculate rides costs

## Usage

```bash
git clone git@github.com:spajic/microservices-test.git
cd microservices-test
RIDE_SERVICE_PORT=9009 GOOGLE_MAPS_API_KEY=secret docker-compose up
curl 'http://localhost:9009/ride_price?from=55.691662,37.503621&to=55.809289,37.582365'
```

## Performance

```bash
ab -c 20 -n 100 'http://localhost:9009/ride_price?from=55.691662,37.503621&to=55.809289,37.582365'
```

Сервис обрабатывает 300 запросов, поступающих в 10 параллельных потоков за 5 секунд.

Это ~3600rpm.

## Tradeoffs

### Map service
Из сервисов из списка
  - Google Directions API
  - Google Distance Matrix API
  - Bing Routes API
  - OpenStreetMap Routing

выбрал Google Distance Matrix API.

Google Directions API даёт более подробную информацию, чем нам нужно.

Из остальных трёх сервис Google, думаю, наиболее качественный.

При выборе map-сервиса для production нужно учесть больше факторов:
  - цену при имеющихся/планируемых нагрузках
  - гарантии доступности
  - скорость работы
  - качество работы в нужных регионах
  - доступность работы в нужных регионах

### go-service
На go решил написать микросервис, работающий с внешним картографическим сервисом.

- На go есть библиотека для работы с выбранным Google Maps API

Микросервис реализован минимумом внешних зависимостей - использую только библиотеку для работы с Google Maps API.

### ruby-service
На ruby решил написать микросервис, предоставляющий http API определения цены.

В перспективе этот сервис мог бы работать с базой данных, например, Redis, или Mongo. Это было бы очень удобно реализовать на ruby.

Микросервис реализован на базе фреймворка `goliath` (https://github.com/postrank-labs/goliath)

`goliath` позволяет очень просто написать сервис, который, за счёт асинхронной работы, в один процесс может держать приличную нагрузку.

### json http vs RPC
json http хорошо подходит для этой задачи своей открытостью и простотой.

Удобно тестировать и использовать оба сервиса по отдельности.

RPC, думаю, было бы избыточно и более сложно.

### File vs Database for tariff
Для этой задачи хранить единственную строчку с одним тарифом в БД было бы перебором.

Заложил в архитектуру микросервиса определения цены возможность передачи id тарифа параметром.

### tests
Написал основные тесты для обоих микросервисов. Потому что считаю, что писать тесты очень полезно и важно.

### Possible improvements
- Поддержка нескольких Map-сервисов в микросервисе, запрашивающем информацию о маршруте (fallback на запасной в случае недоступности/исчерпания дневного лимита)
- Кэширование запросов к микросервисам по координатам с заданной точностью
- Возможность использования разных тарифов (заложено в архитектуру)
- Хранение тарифов в БД
- Развёртывание кластера goliath за reverse-proxy для обработки большей нагрузки
- Размеры docker-images хорошо бы сделать поменьше
- Добавить авторизацию для использования внешнего сервиса
