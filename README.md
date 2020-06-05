# iOS 2020
Group project for mail.ru iOS courses at BMStU

## Приложение для спортивных турниров.

#### Основной функционал
Отображение актуальной информации по футбольным турнирам:
<li>
Данные по турнирам
<li>
Турнирная таблица в двух формтах
<li>
Актуальная статистика команд
<li>
Расписание матчей
<li>
Напоминания о предстоящих матчах 
 
 ![Скриншоты](https://github.com/LDDmarc/LocalFootball/blob/daria/LocalFootball/Presentation/screens.png)

 ## Архитектура
 ![Архитектура](https://github.com/LDDmarc/LocalFootball/blob/daria/LocalFootball/Presentation/Architecture.png)
Проект построен на архитектуре **MVC**. 

Избежать так называймой проблемы *Massive View Controller* позволило следующее:
<li>
 Выделение общей UI логики всех ViewController в отдельный суперкласс.
<li>
 Вынесение работы с календарем в отдельный модуль.
<li>
 Использование классов-конфигураторов для каждой ячейки таблиц.
 
 В проекте так же использован паттерн **Dependency Injection** для сетевого слоя. Создание легко-конфигурируемого класса с тестовыми данными - это удобный инструмент для тестирования различных сценариев и обработки ошибок.
 
 Для хранения данных на устройстве используется **CoreData**, а для отображения этих данных -  **FetchResultsController**.
 
 UI построен с помощью **.xib** - файлов и **AutoLayout**.

### Pods
<li> SwiftyJSON - парсинг данных
<li> SDWebImage - загрузка и отображение изображений
<li> SwiftLint - чистота кода
 
  ## Сетевой слой. Пагинация
Информации для отображения экранов команд и турниров требуется не много, в силу того, что самих команд и турниров ограниченное число. Поэтому все необходимые для них данные грузятся единым запросом. 

Ситуация с матчами другая: число матчей может оказаться велико, поэтому загружать их все разом - не самая лучшая идея. Для дозагрузки матчей в приложении была реализована пагинация. В дальнейшем планируется использование `UITableViewDataSourcePrefetching`.

При обновлении страницы, например если пользователь потянул *pull-to-refresh*, "подтянувшиеся лишние" матчи удаляются из CoreData.

 ![Пагинация](https://github.com/LDDmarc/LocalFootball/blob/daria/LocalFootball/Presentation/pagination.gif)
 
## Взаимодействие с календарем
Было важно учесть все возможные сценарии, среди которых удаление и создание пользователем события в календаре не из нашего приложения. А так же корректность времени матча в календаре, в случае если его перенесли.

## Custom Alert
Для UI обработки ошибок был создан кастомный класс `CustomAlert` с возможностью динамического добавления кнопок и настройки цветовой палитры.
