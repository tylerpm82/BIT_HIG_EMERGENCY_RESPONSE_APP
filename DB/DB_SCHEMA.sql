---
-- title:       database table sketch
-- description: database schema (work-in-progress)
-- date:        2024 may 31
-- for project: HIG_BIT_EMER_APP
-- author(s):   jack l.  
-- filename:    DB_SCHEMA.sql
---

# PEOPLE
# ------------------------------------
create table person (
    id int unsigned auto_increment,
    affiliate_organization_id int unsigned null, 
    alias varchar(100) not null,
    first_name varchar(140) not null,
    last_name varchar(140) not null,
    email_address varchar(240) not null,
    is_a_minor boolean null default false, -- off by default, conditional on ( prompt ) || could use DOB but is that too sketch?
    is_student boolean null default true,
    is_public_safety_official boolean null default false,
    is_campus_school_admin_personnel boolean null default false,
    is_city_municipal_official boolean null default false,
    account_origin_date datetime default null CURRENT_TIMESTAMP(),
    can_report_emergencies boolean null default true,
    can_create_in_app_event boolean null default false,
    can_create_safety_bulletin boolean null default false,
    can_view_safety_bulletin boolean null default true,
    can_make_request_on_extrinsic_account boolean null default false,
    account_info_masked boolean null default true,          -- account info masked by default, affected by view
    allows_requests_on_account boolean null default false   -- no requests made on student-account info (user has to turn this off)
                                                            -- what edge-cases would be justified to override?
                                                            --  
    notification_all_emergencies boolean null default false,
    notification_relative_emergencies boolean null default true,
    notification_all_non_emergencies boolean null default false,
    notification_relative_non_emergencies boolean null default false,
    notification_request_on_account_info_occured boolean null default true,
    last_known_location POINT null,
    primary key (id),
    foreign key (affiliate_organization_id) references organization(id),
    unique(email_address, alias)
);

create table emergency_contact ( 
    -- emergency contacts are non-acounts linked to a person (student, etc) have n_max emergency_contacts
    id int unsigned auto_increment,
    linked_to_this_id int unsigned,
    first_name varchar(140) not null,
    last_name varchar(140) not null,
    email_address varchar(240) not null,
    phone_number char(10) null,
    relationship set ( "parent", "spouse", "relative", "significant other", "guardian", "personal acquaintance" ) not null,
    primary key(id),
    foreign key(linked_to_this_id) references person(id),
    unique(email_address, phone_number)
);

# ENTITIES / ORGANIZATIONS
# ------------------------------------

create table organization (
    id int unsigned auto_increment,
    alias varchar(140) not null,
    main_email_address varchar(240) not null,
    alt_email_address varchar(240) null,
    main_phone_number_a char(10) null,
    alt_phone_number_b char(10) null,
    point_of_contact_is_user boolean null default false,
    college_or_university boolean null default true,
    public_safety_agency boolean null default false,
    municipal_agency boolean null default false,
    commercial_business boolean null default false,
    non_profit_org boolean null default false,
    geographic_coordinates POINT null,
    building_number varchar(32) not null, -- could be A102, etc.
    street_name varchar(120) not null,
    street_type set("street", "road", "boulevard", "blvd") not null, -- limit to valid street types?
    city varchar(120) not null,
    state_abbreviation char(2) not null,
    postal_code char(5) not null,
    -- what can organizations do/not do on-platform??
    --
    --
    primary key(id),
    unique(campus_name, geographic_coordinates)
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
    account_specific boolean null default false
    primary key(id),
    foreign key(relative_campus_id) references campus(id),
    unique(title)
);

# ACCOUNT-SPECIFIC REQUESTS/EVENTS
create table account_inquiry (
    id int unsigned auto_increment,
    inquirer_id int unsigned,
    inquiry_date datetime null default CURRENT_TIMESTAMP(),
    -- to_remove
    -- to_get_account_info
    -- reset_account
    -- < ... >
    additional_detail varchar(320) null,
    primary key (id),
    foreign key (inquirer_id) references person(id)
);

# ------------------------------------

# NON-ACCOUNT INFO-INPUT-CREATION
# ------------------------------------
create table safety_bulletin();
create table feature_request();

# REPORTS
# ------------------------------------
-- verified emergency report
-- de-mystified emergency report
-- incident resolution report
-- safety bulletin report 
-- feature request report
-- account inquiry report
-- account modification and management report
-- campus-agency-venue report
-- platform metric report



