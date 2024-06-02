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
    email_address_main varchar(240) not null,
    email_address_alt varchar(240) null,
    headquarters_city set() null,   -- set of valid city options
    headquarters_state set() null,  -- set of valid state options
    headquarters_country set() null default "US" --
    point_of_contact_is_platform_user boolean null default false,
    type_educational boolean null default false,
    type_non_profit boolean null default false,
    type_government boolean null default false,
    type_municipal boolean null default false,
    type_healthcare boolean null default false,
    type_public_safety boolean null default false,
    industry_sector char(72) null,  -- "this sector" or <non-profit, government, healthcare, ... >
    number_of_employees int unsigned null,
    annual_revenue_estimate int unsigned null,
    mission_statement varchar(140) null,
    description_main_product_service varchar(240) not null,
    url_website varchar(100) null,
    url_twitter varchar(100) null,
    url_instagram varchar(100) null,
    url_facebook varchar(100) null,
    url_tiktok varchar(100) null,
    url_linkedin varchar(100) null,
    url_discord varchar(100) null,
    url_aux_a varchar(100) null, -- auxiliary url
    url_aux_b varchar(100) null, -- auxiliary url
    phone_number_main char(10) null,
    phone_number_alt char(10) null,
    phone_number_emer char(10) null,
    -- what can organizations do/not do on-platform??
    --
    --
    primary key(id),
    unique(alias, url_website, url_twitter, url_instagram, url_facebook, url_tiktok, url_linkedin, url_discord, url_aux_a, url_aux_b)
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
    natural_disaster_earthquake null default false,
    -- natural_disaster_tsunami boolean null, -- not neccessary for mvp; auc is not typhoon-prone
    natural_disaster_hurricane_cyclone_typhoon null default false,
    natural_disaster_tornado null default false,
    natural_disaster_flood null default false,
    natural_disaster_drought null default false,
    natural_disaster_wildfire null default false, -- <type>
    natural_disaster_extreme_heatwave null default false, -- <type>
    natural_disaster_severe_storm_thunderstorm_hail null default false, -- <type>
    natural_disaster_blizzard_snowstrom null default false, -- <type>
    digital_threat_phishing null default false,
    digital_threat_ransomware null default false,
    digital_threat_ddos_attack null default false,
    digital_threat_malware_virus null default false,
    digital_threat_data_breach null default false,
    digital_threat_IT_system_failure null default false,
    digital_threat_electronmagnetic_pulse_attack null default false,
    public_safety_hazard_terrorist_attack null default false,
    public_safety_hazard_active_shoooter null default false,
    public_safety_hazard_chemical_spill_industrial_accident null default false,
    public_safety_hazard_radiological_incident null default false,
    public_safety_hazard_biological_threat null default false,
    public_safety_hazard_plane_train_automobile_crash null default false,
    infrastructure_failure_power_grid_failure boolean null default false,
    infrastructure_failure_structural_collapse boolean null default false,
    infrastructure_failure_power_grid_failure boolean null default false,
    infrastrucutre_failure_water_supply_contamination boolean null default false,
    public_health_emergency_disease_outbreak boolean null default false,
    public_health_emergency_mass_casualty_incident boolean null default false,
    civil_turbulence_riot_public_unrest boolean null default false,
    civil_turbulence_workplace_accident boolean null default false,
    cyber_threat boolean null, -- other, aux
    date_resolved datetime null, -- cannot be resolved until verified, resolved by validator
    primary key (id),
    foreign key (affected_campus_id)    references campus(id),
    foreign key (validator_id)          references public_safety_official(id),
    foreign key (reporter_id)           references student(id)
);

# PLACES / VENUES
# ------------------------------------
-- a building can be registered to the platform
-- spatial domains can be linked to platform organizations
create table spatial_domain (
    id int unsigned auto_increment,
    linked_organization_id int unsigned,
    alias varchar(172) not null,
    description varchar(320) not null,
    maximum_capacity int unsigned null,
    is_college_or_university boolean null default false,
    -- other types of domains below

    -- 
    geographic_coordinates POINT null,
    building_number varchar(32) not null, -- could be A102, etc.
    street_name varchar(120) not null,
    street_type set("street", "road", "boulevard", "blvd") not null, -- limit to valid street types?
    city varchar(120) not null,
    state_abbreviation char(2) not null,
    postal_code char(5) not null,
    primary key(id),
    foreign key(linked_organization_id) references organization(id),
    unique(alias)
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
    account_specific boolean null default false
    primary key(id),
    foreign key(relative_campus_id) references campus(id),
    unique(title)
);

# ACCOUNT-SPECIFIC REQUESTS/EVENTS
# ------------------------------------
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



