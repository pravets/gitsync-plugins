
#Использовать logos
#Использовать gitrunner

Перем Лог;

Перем Обработчик;

Перем ИмяФайлаДампаКонфигурации;
Перем ПутьКФайлуВерсийМетаданных;
Перем ОчиститьКаталогРабочейКопии;
Перем ВыгрузкаИзмененийВозможна;
Перем ИмяРасширения;

#Область Интерфейс_плагина

// Возвращает версию плагина
//
//  Возвращаемое значение:
//   Строка - текущая версия плагина
//
Функция Версия() Экспорт
	Возврат "1.1.1";
КонецФункции

// Возвращает приоритет выполнения плагина
//
//  Возвращаемое значение:
//   Число - приоритет выполнения плагина
//
Функция Приоритет() Экспорт
	Возврат 0;
КонецФункции

// Возвращает описание плагина
//
//  Возвращаемое значение:
//   Строка - описание функциональности плагина
//
Функция Описание() Экспорт
	Возврат "Плагин добавляет возможность инкрементальной выгрузки в конфигурации";
КонецФункции

// Возвращает подробную справку к плагину 
//
//  Возвращаемое значение:
//   Строка - подробная справка для плагина
//
Функция Справка() Экспорт
	Возврат "Справка плагина";
КонецФункции

// Возвращает имя плагина
//
//  Возвращаемое значение:
//   Строка - имя плагина при подключении
//
Функция Имя() Экспорт
	Возврат "increment";
КонецФункции 

// Возвращает имя лога плагина
//
//  Возвращаемое значение:
//   Строка - имя лога плагина
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.lib.gitsync.plugins.increment";
КонецФункции

#КонецОбласти

#Область Подписки_на_события

Процедура ПриАктивизации(СтандартныйОбработчик) Экспорт

	Обработчик = СтандартныйОбработчик;
	ПутьКФайлуВерсийМетаданных = "";
	ВыгрузкаИзмененийВозможна = Ложь;

КонецПроцедуры

// Вызывается перед началом работы менеджера синхронизации
//
// Параметры:
//   ПутьКХранилищу - Строка - полный путь к хранилищу конфигурации 
//   КаталогРабочейКопии - Строка - полный путь к рабочему каталогу копии
//
Процедура ПередНачаломВыполнения(ПутьКХранилищу, КаталогРабочейКопии) Экспорт

	ИмяРасширения = Обработчик.ПолучитьИмяРасширения();

КонецПроцедуры

Процедура ПередВыгрузкойКонфигурациюВИсходники(Конфигуратор, КаталогРабочейКопии, КаталогВыгрузки, ПутьКХранилищу, НомерВерсии) Экспорт

	Консоль = Новый Консоль();
	
	Лог.Информация("Определяю тип возможной выгрузки конфигурации в файлы");
	
	ТекущийФайлВерсийМетаданных = Новый Файл(ОбъединитьПути(КаталогРабочейКопии, ИмяФайлаДампаКонфигурации));

	ПутьКФайлуВерсийМетаданных = ТекущийФайлВерсийМетаданных.ПолноеИмя;

	Лог.Отладка("Проверяю существование файла <%1> в каталоге <%2>, файл <%3>", 
						ИмяФайлаДампаКонфигурации,
						КаталогРабочейКопии,
						?(ТекущийФайлВерсийМетаданных.Существует(), "существует", "отсутствует"));

	Лог.Отладка("Проверяю возможность обновления выгрузки для файла <%1>", ПутьКФайлуВерсийМетаданных);

	ВыгрузкаИзмененийВозможна = ТекущийФайлВерсийМетаданных.Существует()
		И ПроверитьВозможностьОбновленияФайловВыгрузки(Конфигуратор, ПутьКФайлуВерсийМетаданных);

	Лог.Отладка("Инкрементальная выгрузка конфигурации - %1", ?(ВыгрузкаИзмененийВозможна, "ВОЗМОЖНА", "НЕВОЗМОЖНА"));

	Консоль.Вывести("ИНФОРМАЦИЯ - Тип выгрузки конфигурации в файлы:");

	Если ВыгрузкаИзмененийВозможна Тогда
		Текст = "ИНКРЕМЕНТАЛЬНАЯ ВЫГРУЗКА";
	Иначе
		Текст = "ПОЛНАЯ ВЫГРУЗКА";
	КонецЕсли;

	Консоль.Вывести(" " + Текст);

	Консоль.ВывестиСтроку("");
	Консоль = Неопределено;

КонецПроцедуры

Процедура ПриВыгрузкеКонфигурациюВИсходники(Конфигуратор, КаталогВыгрузки, СтандартнаяОбработка) Экспорт

	Если ВыгрузкаИзмененийВозможна Тогда

		СтандартнаяОбработка = ложь;

		Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();
		Параметры.Добавить(СтрШаблон("/DumpConfigToFiles %1", ОбернутьВКавычки(КаталогВыгрузки)));

		Параметры.Добавить("-update");

		Параметры.Добавить(СтрШаблон("-configDumpInfoForChanges %1", ОбернутьВКавычки(ПутьКФайлуВерсийМетаданных)));

		Если ЗначениеЗаполнено(ИмяРасширения) Тогда
			Параметры.Добавить(СтрШаблон("-Extension %1", ИмяРасширения));
		КонецЕсли;

		Конфигуратор.ВыполнитьКоманду(Параметры);

	КонецЕсли;

КонецПроцедуры

Процедура ПриОчисткеКаталогаРабочейКопии(КаталогРабочейКопии, СоответствиеИменФайловДляПропуска, СтандартнаяОбработка) Экспорт

	Если ВыгрузкаИзмененийВозможна Тогда
		СтандартнаяОбработка = Ложь;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область Вспомогательные_процедуры_и_функции

// Функция проверяет возможность обновления файлов выгрузки, для каталога или конкретного файла версий
//
// Параметры:
//   Конфигуратор - <Тип.Вид> - <описание параметра>
//   КаталогВыгрузки - Строка - временный каталог
//   ПутьКФайлуВерсийДляСравнения - Строка - <описание параметра>
//
//  Возвращаемое значение:
//   Булево - обновление возможно?
//

Функция ПроверитьВозможностьОбновленияФайловВыгрузки(Конфигуратор, Знач ПутьКФайлуВерсийДляСравнения = "")

	ОбновлениеВозможно = Ложь;

	КаталогПроверки = ВременныеФайлы.СоздатьКаталог();
	
	ТекущийФайлВерсийМетаданных = Новый Файл(ОбъединитьПути(КаталогПроверки, "ConfigDumpInfo.xml"));

	Если ПустаяСтрока(ПутьКФайлуВерсийДляСравнения) Тогда
	 	Возврат ОбновлениеВозможно;
	КонецЕсли;

	ПутьКФайлуИзменений = ВременныеФайлы.НовоеИмяФайла();

	Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();
	Параметры.Добавить(СтрШаблон("/DumpConfigToFiles %1", ОбернутьВКавычки(КаталогПроверки)));
	Параметры.Добавить(СтрШаблон("-getChanges %1", ОбернутьВКавычки(ПутьКФайлуИзменений)));

	Если ЗначениеЗаполнено(ИмяРасширения) Тогда
		Параметры.Добавить(СтрШаблон("-Extension %1", ИмяРасширения));
	КонецЕсли;

	Если ЗначениеЗаполнено(ПутьКФайлуВерсийДляСравнения) Тогда

		Параметры.Добавить(СтрШаблон("-configDumpInfoForChanges %1", ОбернутьВКавычки(ПутьКФайлуВерсийДляСравнения)));

	КонецЕсли;

	Конфигуратор.ВыполнитьКоманду(Параметры);

	ФайлИзменений = Новый Файл(ПутьКФайлуИзменений);

	Если ФайлИзменений.Существует() Тогда
		СтрокаПолныйДамп = ВРег("FullDump");
		ЧтениеФайла = Новый ЧтениеТекста(ПутьКФайлуИзменений);
		СтрокаВыгрузки = Лев(ВРег(ЧтениеФайла.ПрочитатьСтроку()), СтрДлина(СтрокаПолныйДамп));

		Если Не ПустаяСтрока(СокрЛП(СтрокаВыгрузки)) Тогда

			Лог.Отладка("Строка проверки на возможность выгрузки конфигурации: <%1> = <%2> ", СтрокаПолныйДамп, СтрокаВыгрузки);
			ОбновлениеВозможно = НЕ (СтрокаВыгрузки = СтрокаПолныйДамп);

		КонецЕсли;
		ЧтениеФайла.Закрыть();

		ВременныеФайлы.УдалитьФайл(ПутьКФайлуИзменений);
	КонецЕсли;

	ВременныеФайлы.УдалитьФайл(КаталогПроверки);

	Возврат ОбновлениеВозможно;

КонецФункции
Функция ОбернутьВКавычки(Знач Строка)
	Возврат """" + Строка + """";
КонецФункции

Процедура Инициализация()

	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	ПутьКФайлуВерсийМетаданных = "";
	ИмяФайлаДампаКонфигурации = "ConfigDumpInfo.xml";
	ВыгрузкаИзмененийВозможна = Ложь;
	ИмяРасширения = "";

КонецПроцедуры

#КонецОбласти

Инициализация();
