---
-- title:       database table sketch
-- description: database schema a/k/a sketch (work-in-progress)
-- date:        2024 may 31 (genesis)
-- for project: HIG_BIT_EMER_RESPONSE_UPSTART
-- author(s):   jack l.  
-- filename:    DB_SCHEMA.sql
---

# PEOPLE
# ------------------------------------
create table Person (
    id int unsigned auto_increment,
    affiliate_organization_id int unsigned null, 
    alias varchar(100) not null,
    first_name varchar(140) not null,
    last_name varchar(140) not null,
    email_address varchar(240) not null,
    is_a_minor boolean null default false, -- off by default, conditional on ( prompt ) || could use dob but is that too sketch?
    is_student boolean null default true,
    is_public_safety_official boolean null default false,
    is_campus_school_admin_personnel boolean null default false,
    is_city_municipal_official boolean null default false,
    account_origin_date datetime default null current_timestamp(),
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
    last_known_location point null,
    primary key (id),
    foreign key (affiliate_organization_id) references organization(id),
    unique(email_address, alias)
);

create table EmergencyContact ( 
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

create table Organization (
    id int unsigned auto_increment,
    alias varchar(140) not null,
    email_address_main varchar(240) not null,
    email_address_alt varchar(240) null,
    headquarters_city set() null,   -- set of valid city options
    headquarters_state set() null,  -- set of valid state options
    headquarters_country set() null default "us" --
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
    unique
    ( 
        alias, 
        url_website, 
        url_twitter, 
        url_instagram, 
        url_facebook, 
        url_tiktok, 
        url_linkedin, 
        url_discord, 
        url_aux_a, 
        url_aux_b
    )
);

# EVENTS
# ------------------------------------
create table Emergency (
    id int unsigned auto_increment,
    reporter_id int unsigned,
    affected_campus_id int unsigned,
    validator_id int unsigned null,
    date_occured datetime null default current_timestamp(),
    validated_as_legit boolean null default false,
    description_of_emergency varchar(320) not null,
    description_of_location varchar(320) null,
    location_coordinates point not null, -- point(latitude, longitude)
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
    digital_threat_it_system_failure null default false,
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
create table SpatialDomain (
    id int unsigned auto_increment,
    linked_owner_id int unsigned null,
    linked_organization_id int unsigned null,
    domain_type_id int unsigned null,
    usage_intent_id int unsigned null, -- ""
    usage_type set("residential", "commercial", "industrial", "recreational", "mixed-use"),
    alias varchar(172) not null,
    description varchar(320) not null,
    maximum_capacity int unsigned null,
    area_in_sqaure_feet int unsigned null,
    area_in_acres decimal(4,2) unsigned null,
    number_of_floors int null,
    construction_date datetime null, 
    number_of_emergency_exits int null,
    fire_safety_compliant boolean null,
    open_to_public boolean null,
    accessibility_feature_elevators boolean null,
    accessibility_feature_wide_corridors boolean null,
    accessibility_feature_braille_tactile_signage boolean null,
    accessibility_adult_change_facility_public_toilet boolean null,
    accessibility_feature_stairs boolean null,  -- conditionally irrelevant if space is 1 floor
    accessibility_feature_ramps boolean null,
    accessibility_feature_elevators boolean null,
    -- what other  accessibility features
    --
    --
    --
    utilities_available_water boolean null,
    utilities_available_gas boolean null,
    utilities_available_internet boolean null,
    utilities_available_electricity boolean null,
    security_feature_cctv boolean null,
    security_feature_human_security_guards boolean null,
    security_feautre_technoloy_enhanced_security_guards boolean null,
    security_feature_access_control boolean null,
    security_feature_biometric_scanners boolean null,
    security_feature_facial_recognition_systems boolean null,
    -- what other security features
    --
    --
    --
    emergency_plan_on_file boolean null,
    maintenance_records_on_file boolean null,
    has_associated_beacons boolean null default false,
    additiional_note_a varchar(140) null,
    additiional_note_b varchar(140) null,
    additiional_note_c varchar(140) null,
    additiional_note_d varchar(140) null,
    geographic_coordinates point null,
    building_number varchar(32) not null, -- could be a102, etc.
    street_name varchar(120) not null,
    street_type set("street", "road", "boulevard", "blvd") not null, -- limit to valid street types?
    city varchar(120) not null,
    state_abbreviation char(2) not null,
    postal_code char(5) not null,
    primary key(id),
    foreign key(linked_owner_id) references person(id),
    foreign key(linked_organization_id) references organization(id),
    foreign key(domain_type_id) references domain_type(id),
    foreign key(usage_intent_id) references usage_intent(id),
    unique(alias)
);

# DEVICES
-- having devices registered/linked to the platform diversfies location-gps capabilities.
-- beacons connected to domain's wifi OR via a hardline ..
create table Device (
    id int unsigned auto_increment,
    spatial_domain_id int unsigned,
    manufacturer_supplier_id int unsigned,
    alias varchar(72) not null,
    ip_address int unsigned null,                       -- store/retrieve with inet_anon(<ip_address>)
    media_access_control_address bigint unsigned null,  -- store as x'<macaddress>' retrieve as hex(mac_address)
    model_number varchar(72) not null,
    battery_status decimal(4,2) null,                   -- 99.99
    connectivity_type set("bluetooth", "wifi", "cellular", "lan", "wan") null,
    pre_install_test_date datetime null, 
    installation_date datetime null,    -- a device can exist and have no installation date (implies it is uninstalled)
    operational boolean null default false,
    deployed boolean null default false,
    deployment_environment set("indoor", "outdoor") null,
    total_associated_incidents int unsigned null default 0,
    last_associated_incident datetime null,
    last_maintenance_date datetime null,
    location_description varchar(120) not null,
    location_coordinates point null,
    beacon_type set(""),
    additional_note_a varchar(140) null,
    additional_note_b varchar(140) null,
    additional_note_c varchar(140) null,
    additional_note_d varchar(140) null,
    optimal_maintenance_frequency set 
        (
            "hourly", 
            "daily", 
            "weekly", 
            "bi-weekly", 
            "monthly", 
            "quarterly", 
            "tri-monthly", 
            "semi-annually", 
            "annual"
        ) null,
    primary key(id),
    foreign key(spatial_domain_id)          references spatial_domain(id) -- devices in the wild are linked to some spatial domain
    foreign key(manufacturer_supplier_id)   references organization(id),
    unique(alias)
);


# NOTIFICATIONS
# ------------------------------------
create table Announcement (
    id int unsigned auto_increment,
    relative_campus_id int unsigned,
    title varchar(100) not null,
    description varchar(240) not null,
    origin_date datetime null default current_timestamp(),
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
create table AccountInquiry (
    id int unsigned auto_increment,
    inquirer_id int unsigned,
    inquiry_date datetime null default current_timestamp(),
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
create table SafetyBulletin();
create table FeatureRequest();

# REPORTS
# ------------------------------------

-- PUBLIC-SAFETY
-- incident_summary
-- geographical_impact_analysis
-- response_time_analysis
-- resource_alloication_report
-- crime_incident
-- public_health_incident
-- infrastructure_failure_analyis
-- transportation_accident_overview
-- trend_analysis_in_emergency_incidents

-- HARDWARE-AND-DEVICES (these are the platform's beacons, not personal user devices)
-- device_health
-- usage_statistics
-- maintenance_log
-- sensor_data
-- location_impact_analysis

-- DIGITAL-THREATS
-- cyber_attack_summary
-- data_breach_analysis
-- IT_system_downtime
-- threat_detection_efficiency

-- MULTI-INDUSTRY
-- all_hazards_incident
-- business_continuity_plan_effectiveness
-- impact_on_supply_chain_operations

-- POLITICAL SECTOR
-- emergency_policy_compliance
-- resource_deployment_analysis
-- legislative_impact
-- cross_geofence_incident_analysis

-- ANALYTICAL
-- predictive_analytics
-- sentiment_analysis
-- anomaly_detection_in_incident_data   (pattern recognition, frequency analyis, risk indicators)
-- trend_analysis_in_emergency_incidents
-- performance_metrics_dashboard
-- threat_forecasting
-- vulnerability_assessment
-- impact_simulation

-- SENTIMENT-ANALYSIS
-- public_sentiment
-- platform_communication_trends
-- organization_community_communication_effectiveness

-- PLATFORM-AND-USERS
-- user_activity
-- account_usage
-- security_incident_report
-- system_performance
-- feedback_and_support
-- safety bulletin report 