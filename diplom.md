# Задание можно посмотреть по ссылке:
## [SYS-DIPLOM](https://github.com/netology-code/sys-diplom)


Создаю инфраструктуру с помощью terraform. Прописываю **yes** и жду создания.

![1](https://github.com/VovanBanks/diplomsys16/blob/master/img/1.PNG)


Для помощи в дальнейшем установил интерфейс командной строки Яндекс 


`` https://cloud.yandex.ru/docs/cli/quickstart#install
``


Смотрим список всех ВМ и их айпи адреса (**test** - моя машина с дипломным проектом):


![2](https://github.com/VovanBanks/diplomsys16/blob/master/img/2.PNG)

![3](https://github.com/VovanBanks/diplomsys16/blob/master/img/3.PNG)

VPC (**net_project** - для диплома): 

![4](https://github.com/VovanBanks/diplomsys16/blob/master/img/4.PNG)

Группы безопасности:

![5](https://github.com/VovanBanks/diplomsys16/blob/master/img/5.PNG)

Файл **inventory.ini**. Список хостов для **Ansible**:

![6](https://github.com/VovanBanks/diplomsys16/blob/master/img/6.PNG)

Пингую (последний - мой балансировщик):

![7](https://github.com/VovanBanks/diplomsys16/blob/master/img/7.PNG)

Запускаю плейбук для установки **Elasticsearch**

Затем сразу же захожу через **bastion-host** на сервер и проверяю работу сервиса.

Зашел с помощью команды

``ssh -i ~/.ssh/id_rsa -J user@51.250.41.6 user@10.0.3.4
``

![8](https://github.com/VovanBanks/diplomsys16/blob/master/img/8.PNG)

Запускаю плейбук для установки **filebeat**:

![9](https://github.com/VovanBanks/diplomsys16/blob/master/img/9.PNG)

Запускаю плейбук для установки **kibana**

Затем также захожу через **bastion-host** на сервер и проверяю работу сервиса.

Зашел с помощью команды

``ssh -i ~/.ssh/id_rsa -J user@51.250.41.6 user@10.0.4.3
``

![10](https://github.com/VovanBanks/diplomsys16/blob/master/img/10.PNG)

Запускаю плейбук для установки **nginx**:

![11](https://github.com/VovanBanks/diplomsys16/blob/master/img/11.PNG)

Запускаю плейбук для установки **log-exporter**:

![12](https://github.com/VovanBanks/diplomsys16/blob/master/img/12.PNG)

Запускаю плейбук для установки **node-exporter**:

![13](https://github.com/VovanBanks/diplomsys16/blob/master/img/13.PNG)

Запускаю плейбук для установки **prometheus**:

![14](https://github.com/VovanBanks/diplomsys16/blob/master/img/14.PNG)

Затем захожу через **bastion-host** на сервер и проверяю работу сервиса.

Зашел с помощью команды

``ssh -i ~/.ssh/id_rsa -J user@51.250.41.6 user@10.0.3.3
``

![15](https://github.com/VovanBanks/diplomsys16/blob/master/img/15.PNG)

Запускаю плейбук для установки **grafana**:

![16](https://github.com/VovanBanks/diplomsys16/blob/master/img/16.PNG)

Затем захожу через **bastion-host** на веб-сервера, куда ставил несколько определенных для работы сервисов и проверяю их работу.

Зашел с помощью команды

``ssh -i ~/.ssh/id_rsa -J user@51.250.41.6 user@10.0.1.3
``

``ssh -i ~/.ssh/id_rsa -J user@51.250.41.6 user@10.0.2.3
``

![17](https://github.com/VovanBanks/diplomsys16/blob/master/img/17.PNG)

![18](https://github.com/VovanBanks/diplomsys16/blob/master/img/18.PNG)

Затем захожу на сайт графаны по адресу

``http://84.201.149.156:3000
``

Пароль и логин **admin:admin**

Затем добавляю в дашборд код из своего файла **dashboard.md**, чтобы смотреть необходимые метрики.

![19](https://github.com/VovanBanks/diplomsys16/blob/master/img/19.PNG)

Совсем забыл про тест балансировщика:


![20](https://github.com/VovanBanks/diplomsys16/blob/master/img/20.PNG)

**Доработка**:

Решил проверить бьется ли с веб-серверами мой балансировщик:

![26](https://github.com/VovanBanks/diplomsys16/blob/master/img/26.PNG)

![27](https://github.com/VovanBanks/diplomsys16/blob/master/img/27.PNG)

![29](https://github.com/VovanBanks/diplomsys16/blob/master/img/29.PNG)

Возвращаемся к **grafana** и смотрим сбор метрик:

![21](https://github.com/VovanBanks/diplomsys16/blob/master/img/21.PNG)

Затем захожу на **kibana**

``http://84.201.149.156:3000
``

Смотрю взаимодействие с **filebeat**:

![22](https://github.com/VovanBanks/diplomsys16/blob/master/img/22.PNG)

**Доработка**:

Смотрим логи **nginx**:

![25](https://github.com/VovanBanks/diplomsys16/blob/master/img/25.PNG)

Снимки дисков:

![23](https://github.com/VovanBanks/diplomsys16/blob/master/img/23.PNG)

Создание расписания:

![24](https://github.com/VovanBanks/diplomsys16/blob/master/img/24.PNG)

После **доработки** сделал расписание (снимки создаются раз в сутки в 03:00) через **terraform**:

![30](https://github.com/VovanBanks/diplomsys16/blob/master/img/30.PNG)

![28](https://github.com/VovanBanks/diplomsys16/blob/master/img/28.PNG)


**Благодарю за обучение!**
