---
-- title:       DB_SCHEMA.sql
-- description: database schema for emergency response application
-- for project: HIG_BIT_EMER_APP
-- date:        2024 may 31
-- author(s):   jack l.  
---

# PEOPLE
# ------------------------------------
create table public_safety_official();
create table campus_school_administrator_personnel();
create table city_municipal_official();
create table student (
    id int unsigned auto_increment,
    school_id int unsigned,
    alias varchar(100) not null,
    first_name varchar(140) not null,
    last_name varchar(140) not null,
    email_address varchar(240) not null,
    can_report_emergencies boolean null default true,
    can_create_in_app_event boolean null default false,
    can_create_safety_bulletin boolean null default false,
    can_view_safety_bulletin boolean null default true,
    last_known_location POINT null,
    primary key (id),
    foreign key (school_id) references school(id),
    unique(email_address, alias)
);

create table emergency_contact ( 
    -- emergency contacts are linked to students. students can have n_max emergency_contacts
    id int unsigned auto_increment,
    student_id int unsigned,
    first_name varchar(140) not null,
    last_name varchar(140) not null,
    email_address varchar(240) not null,
    phone_number char(10) null,
    relationship_to_student set ("parent", "spouse", "relative", "significant other", "guardian") not null,
    can_report_emergencies boolean null default false,
    can_create_in_app_event boolean null default false,
    can_create_safety_bulletin boolean null default false,
    can_view_safety_bulletin boolean null default true
    primary key(id),
    foreign key(student_id) references student(id),
    unique(email_address, phone_number)
);

# EVENTS
# ------------------------------------
create table emergency (
    id int unsigned auto_increment,
    reporter_id int unsigned,
    affected_campus_id int unsigned,
    validator_id int unsigned null,
    date_occured datetime null default CURRENT_TIMESTAMP(),
    validated_as_legit boolean null default false,
    description_of_emergency varchar(320) not null,
    description_of_location varchar(320) null,
    location_coordinates POINT not null, -- POINT(LATITUDE, LONGITUDE)
    emergency_type_a boolean null, -- <type>
    emergency_type_b boolean null, -- <type>
    emergency_type_c boolean null, -- <type>
    emergency_type_d boolean null, -- <type>
    emergency_type_e boolean null, -- <type>
    emergency_type_f boolean null, -- other, aux
    date_resolved datetime null, -- cannot be resolved until verified, resolved by validator
    primary key(id),
    foreign key (affected_campus_id) references campus(id),
    foreign key(validator_id) references public_safety_official(id),
    foreign key (reporter_id) references student(id)
);

# PLACES / VENUES
# ------------------------------------
create table venue();
create table campus(
    id int unsigned auto_increment,
    campus_name varchar(140) not null,
    email_address varchar(240) not null,
    phone_number char(10) null,
    geographic_coordinates POINT null,
    building_number varchar(32) not null, -- could be A102, etc.
    street_name varchar(120) not null,
    street_type set("street", "road", "boulevard", "blvd"), -- limit to valid street types?
    city varchar(120) null default "Atlanta",
    state_abbreviation char(2) null default "GA",
    postal_code char(5) null,
    primary key(id),
    unique(campus_name, geographic_coordinates)
);

# NOTIFICATIONS
# ------------------------------------
create table announcement (
    id int unsigned auto_increment,
    relative_campus_id int unsigned,
    title varchar(100) not null,
    description varchar(240) not null,
    origin_date datetime null default CURRENT_TIMESTAMP(),
    good_until_date datetime not null,
    emergency boolean null default false,
    local_event boolean null default false,
    feedback_and_app_support boolean null default false,
    primary key(id),
    foreign key(relative_campus_id) references campus(id),
    unique(title)
);

# REPORTS
# ------------------------------------
create table emergency_report();
create table safety_bulletin();
 