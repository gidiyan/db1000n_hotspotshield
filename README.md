# Скрипт-обгортка для запуску потужного DDoS інструмента [db1000n](https://arriven.github.io/db1000n).

- **Не потребує VPN** - скачує і підбирає робочі проксі для атаки
- Атака **декількох цілей** з автоматичним балансуванням навантаження
- Використовує **різноманітні методи для атаки**

### ⏱ Останні оновлення

- **19.04.2022** Залишено три локації для більшої еффективності. Можливо замінити на повний пеерлік в тілі срипта
- **09.04.2022** Додано автоматичне перепідключення до VPN Hotspot Shield з рандомною локацією
- **09.04.2022** Оновлено інструкції всередині скрипта
- **09.04.2022** Змінено кольори у виводах команди
- **05.04.2022** Додано автоматичне встановлення VPN Hotspot Shield для використання при use_proxy=false

## Death by 1000 needles

See [Docs](https://arriven.github.io/db1000n)

This is a simple distributed load generation client written in go.
It is able to fetch simple json config from a local or remote location.
The config describes which load generation jobs should be launched in parallel.
There are other existing tools doing the same kind of job.
I do not intend to copy or replace them but rather provide a simple open source alternative so that users have more options.
Feel free to use it in your load tests (wink-wink).

The software is provided as is under no guarantee.
I will update both the repo and this doc as I go during following days (date of writing this is 26th of February 2022, third day of Russian invasion into Ukraine).

[Gitlab mirror](https://gitlab.com/db1000n/db1000n.git)
