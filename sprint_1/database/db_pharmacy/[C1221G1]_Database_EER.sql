DROP DATABASE IF EXISTS c12_pharmacy;
CREATE DATABASE c12_pharmacy;

USE c12_pharmacy;


DROP TABLE IF EXISTS customer_type;
CREATE TABLE customer_type
(
    customer_type_id   int PRIMARY KEY,
    customer_type_name varchar(25)
);
DROP TABLE IF EXISTS customer;
CREATE TABLE customer
(
    customer_id       varchar(20) PRIMARY KEY,
    customer_name     varchar(50),
    customer_age      int,
    customer_address  varchar(50),
    customer_phone    varchar(11),
    customer_username varchar(255),
    customer_note     varchar(50),
    flag              bit,
    customer_type_id  int,
    FOREIGN KEY (customer_type_id) REFERENCES customer_type (customer_type_id),
    FOREIGN KEY (customer_username) REFERENCES `users` (username)
);

CREATE TABLE medicine_unit
(
    medicine_unit_id   int AUTO_INCREMENT,
    medicine_unit_name varchar(50),
    PRIMARY KEY (medicine_unit_id)
);

CREATE TABLE medicine_conversion_unit
(
    medicine_conversion_unit_id   int AUTO_INCREMENT,
    medicine_conversion_unit_name varchar(50),
    PRIMARY KEY (medicine_conversion_unit_id)
);

CREATE TABLE medicine_type
(
    medicine_type_id   varchar(20),
    medicine_type_name varchar(25) NOT NULL UNIQUE,
    flag               boolean,
    PRIMARY KEY (medicine_type_id)
);

CREATE TABLE medicine
(
    medicine_id                 varchar(20),
    medicine_name               varchar(50),
    medicine_active_ingredients varchar(255),
    medicine_quantity           int,
    medicine_import_price       double,
    medicine_wholesale_price    double,
    medicine_retail_price       double,
    medicine_discount           double,
    medicine_wholesale_profit   double,
    medicine_retail_sale_profit double,
    medicine_tax                double,
    medicine_type_id            varchar(50),
    medicine_unit_id            int,
    medicine_conversion_unit_id int,
    PRIMARY KEY (medicine_id),
    FOREIGN KEY (medicine_type_id) REFERENCES medicine_type (medicine_type_id),
    FOREIGN KEY (medicine_unit_id) REFERENCES medicine_unit (medicine_unit_id),
    FOREIGN KEY (medicine_conversion_unit_id) REFERENCES medicine_conversion_unit (medicine_conversion_unit_id)
);

CREATE TABLE position
(
    position_id   integer NOT NULL AUTO_INCREMENT,
    position_name varchar(255),
    PRIMARY KEY (position_id)
) ENGINE = InnoDB;

CREATE TABLE employee
(
    employee_id         VARCHAR(20) NOT NULL,
    employee_address    varchar(255),
    employee_date_start DATE,
    employee_image      LONGTEXT,
    employee_name       varchar(255),
    employee_note       varchar(255),
    employee_phone      varchar(255),
    flag                BIT,
    position_id         integer,
    employee_username   varchar(255),
    PRIMARY KEY (employee_id),
    FOREIGN KEY (position_id) REFERENCES `position` (position_id)
) ENGINE = InnoDB;

CREATE TABLE roles
(
    role_id   integer NOT NULL AUTO_INCREMENT,
    role_name varchar(255),
    PRIMARY KEY (role_id)
) ENGINE = InnoDB;
CREATE TABLE user_role
(
    user_role_id integer NOT NULL AUTO_INCREMENT,
    role_id      integer,
    username     varchar(255),
    PRIMARY KEY (user_role_id)
) ENGINE = InnoDB;

CREATE TABLE users
(
    username varchar(255) NOT NULL,
    password varchar(255),
    flag     bit,
    PRIMARY KEY (username)
) ENGINE = InnoDB;

ALTER TABLE employee
    ADD CONSTRAINT FKbc8rdko9o9n1ri9bpdyxv3x7i FOREIGN KEY (position_id) REFERENCES position (position_id);
ALTER TABLE employee
    ADD CONSTRAINT FKm5ew6m4dykuysmbppfpgrlaia FOREIGN KEY (employee_username) REFERENCES users (username);
ALTER TABLE user_role
    ADD CONSTRAINT FKt7e7djp752sqn6w22i6ocqy6q FOREIGN KEY (role_id) REFERENCES roles (role_id);
ALTER TABLE user_role
    ADD CONSTRAINT FK2svos04wv92op6gs17m9omli1 FOREIGN KEY (username) REFERENCES users (username);


CREATE TABLE type_of_invoice
(
    type_of_invoice_id   INT PRIMARY KEY AUTO_INCREMENT,
    type_of_invoice_name VARCHAR(45)
);
CREATE TABLE invoice
(
    invoice_id         varchar(45) PRIMARY KEY,
    customer_id        varchar(45),
    employee_id        varchar(45),
    type_of_invoice_id int,
    note               longtext,
    created_date       varchar(45),
    flag               bit,
    CONSTRAINT fk_type_of_invoice FOREIGN KEY (type_of_invoice_id)
        REFERENCES type_of_invoice (type_of_invoice_id),
    CONSTRAINT fk_customer_invoice FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),
    CONSTRAINT fk_employee_invoice FOREIGN KEY (employee_id)
        REFERENCES employee (employee_id)
);


CREATE TABLE invoice_medicine
(
    invoice_id  varchar(45),
    medicine_id varchar(45),
    PRIMARY KEY (invoice_id, medicine_id),
    CONSTRAINT fk_invoice_id FOREIGN KEY (invoice_id)
        REFERENCES invoice (invoice_id),
    CONSTRAINT fk_medicine_id FOREIGN KEY (medicine_id)
        REFERENCES medicine (medicine_id),
    quantity    int
);

CREATE TABLE prescription
(
    prescription_id   bigint PRIMARY KEY AUTO_INCREMENT,
    prescription_name varchar(100),
    symptom           varchar(100),
    object            varchar(50),
    number_of_days    int,
    flag              bit
);

CREATE TABLE medicine_prescription
(
    medicine_id     varchar(20),
    prescription_id bigint,
    PRIMARY KEY (medicine_id, prescription_id),
    times           int,
    number_per_time int,
    FOREIGN KEY (medicine_id) REFERENCES medicine (medicine_id),
    FOREIGN KEY (prescription_id) REFERENCES prescription (prescription_id)
);


CREATE TABLE supplier
(
    supplier_id      varchar(20)  NOT NULL PRIMARY KEY,
    supplier_name    varchar(100) NOT NULL,
    supplier_address varchar(255) NOT NULL,
    supplier_phone   varchar(20)  NOT NULL,
    supplier_email   varchar(30)  NOT NULL,
    note             text,
    flag             bit
);

CREATE TABLE payment
(
    payment_id       bigint NOT NULL AUTO_INCREMENT,
    payment_discount integer,
    prepayment       double precision,
    PRIMARY KEY (payment_id)
);

CREATE TABLE import_invoice
(
    import_invoice_id         bigint      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    import_system_code        int         NOT NULL, -- số hợp đồng
    accounting_voucher_number int         NOT NULL, -- số chứng từ
    import_invoice_date       varchar(100),
    flag                      bit         NOT NULL,
    payment_id                bigint      NOT NULL,
    supplier_id               varchar(20) NOT NULL,
    employee_id               varchar(20) NOT NULL,
    CONSTRAINT payment_id FOREIGN KEY (payment_id) REFERENCES payment (payment_id),
    CONSTRAINT supplier_id FOREIGN KEY (supplier_id) REFERENCES supplier (supplier_id),
    CONSTRAINT employee_id FOREIGN KEY (employee_id) REFERENCES employee (employee_id)
);

CREATE TABLE import_invoice_medicine
(
    import_invoice_medicine_id bigint      NOT NULL AUTO_INCREMENT,
    discount_rate              int,
    expiry                     date,
    flag                       bit         NOT NULL,
    import_quantity            int,
    import_price               double precision,
    lot_number                 int,
    vat                        int,
    medicine_id                varchar(20) NOT NULL,
    import_invoice_id          bigint      NOT NULL,
    PRIMARY KEY (import_invoice_medicine_id),
    CONSTRAINT import_invoice_id FOREIGN KEY (import_invoice_id) REFERENCES import_invoice (import_invoice_id),
    CONSTRAINT medicine_id FOREIGN KEY (medicine_id) REFERENCES medicine (medicine_id)
);


CREATE TABLE cart
(
    cart_id     int AUTO_INCREMENT PRIMARY KEY,
    cart_status bit,
    customer_id varchar(40),
    date_create date,
    FOREIGN KEY (customer_id) REFERENCES `customer` (customer_id)
);

CREATE TABLE cart_detail
(
    cart_detail_id int AUTO_INCREMENT PRIMARY KEY,
    medicine_id    varchar(20),
    cart_id        int,
    quantity       int,
    FOREIGN KEY (medicine_id) REFERENCES `medicine` (medicine_id),
    FOREIGN KEY (cart_id) REFERENCES `cart` (cart_id),
    CONSTRAINT UC_cart_detail UNIQUE (medicine_id, cart_id)
);

CREATE TABLE payment_online
(
    payment_id  int AUTO_INCREMENT PRIMARY KEY,
    cart_id     int,
    discount    float,
    time_create datetime,
    note        varchar(255),
    FOREIGN KEY (cart_id) REFERENCES `cart` (cart_id)
);