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

 ## Архитектура
 ![Архитектура](https://github.com/LDDmarc/LocalFootball/blob/daria/LocalFootball/Presentation/Architecture.png)
Проект построен на архитектуре **MVC**. 

Избежать так называймой проблемы `Massive View Controller` позволило следующее:
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
 
 

