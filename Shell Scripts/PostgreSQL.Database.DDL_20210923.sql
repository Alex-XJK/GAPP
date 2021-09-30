create table public.schema_migrations
(
	version varchar not null
		constraint schema_migrations_pkey
			primary key
);

alter table public.schema_migrations owner to gapp_db;

create table public.ar_internal_metadata
(
	key varchar not null
		constraint ar_internal_metadata_pkey
			primary key,
	value varchar,
	created_at timestamp(6) not null,
	updated_at timestamp(6) not null
);

alter table public.ar_internal_metadata owner to gapp_db;

create table public.analyses
(
	id bigserial
		constraint analyses_pkey
			primary key,
	name varchar not null,
	doap_id integer not null
);

alter table public.analyses owner to gapp_db;

create table public.apps
(
	id bigserial
		constraint apps_pkey
			primary key,
	app_no varchar,
	name varchar not null,
	price integer not null,
	description text not null,
	create_report boolean default false,
	status varchar default 'offline'::character varying,
	user_id bigint,
	analysis_id bigint,
	category_id bigint,
	cover_image varchar,
	panel varchar,
	created_at timestamp(6) not null,
	updated_at timestamp(6) not null
);

alter table public.apps owner to gapp_db;

create index index_apps_on_user_id
	on public.apps (user_id);

create index index_apps_on_analysis_id
	on public.apps (analysis_id);

create index index_apps_on_category_id
	on public.apps (category_id);

create table public.active_storage_blobs
(
	id bigserial
		constraint active_storage_blobs_pkey
			primary key,
	key varchar not null,
	filename varchar not null,
	content_type varchar,
	metadata text,
	byte_size bigint not null,
	checksum varchar not null,
	created_at timestamp not null
);

alter table public.active_storage_blobs owner to gapp_db;

create unique index index_active_storage_blobs_on_key
	on public.active_storage_blobs (key);

create table public.active_storage_attachments
(
	id bigserial
		constraint active_storage_attachments_pkey
			primary key,
	name varchar not null,
	record_type varchar not null,
	record_id bigint not null,
	blob_id bigint not null
		constraint fk_rails_c3b3935057
			references public.active_storage_blobs,
	created_at timestamp not null
);

alter table public.active_storage_attachments owner to gapp_db;

create index index_active_storage_attachments_on_blob_id
	on public.active_storage_attachments (blob_id);

create unique index index_active_storage_attachments_uniqueness
	on public.active_storage_attachments (record_type, record_id, name, blob_id);

create table public.roles
(
	id bigserial
		constraint roles_pkey
			primary key,
	name varchar,
	created_at timestamp(6) not null,
	updated_at timestamp(6) not null
);

alter table public.roles owner to gapp_db;

create table public.categories
(
	id bigserial
		constraint categories_pkey
			primary key,
	name varchar not null,
	initial varchar,
	serial bigint,
	created_at timestamp,
	updated_at timestamp
);

alter table public.categories owner to postgres;

grant select, usage on sequence public.categories_id_seq to gapp_db;

grant delete, insert, references, select, trigger, truncate, update on public.categories to gapp_db;

create table public.accounts
(
	id bigserial
		constraint accounts_pkey
			primary key,
	email varchar default ''::character varying not null,
	encrypted_password varchar default ''::character varying not null,
	reset_password_token varchar,
	reset_password_sent_at timestamp,
	remember_created_at timestamp,
	sign_in_count integer default 0 not null,
	current_sign_in_at timestamp,
	last_sign_in_at timestamp,
	current_sign_in_ip inet,
	last_sign_in_ip inet,
	confirmation_token varchar,
	confirmed_at timestamp,
	confirmation_sent_at timestamp,
	unconfirmed_email varchar,
	failed_attempts integer default 0 not null,
	unlock_token varchar,
	locked_at timestamp,
	created_at timestamp(6) not null,
	updated_at timestamp(6) not null,
	invitation_token varchar,
	invitation_created_at timestamp,
	invitation_sent_at timestamp,
	invitation_accepted_at timestamp,
	invitation_limit integer,
	invited_by_type varchar,
	invited_by_id bigint,
	invitations_count integer default 0
);

alter table public.accounts owner to gapp_db;

create table public.users
(
	id bigserial
		constraint users_pkey
			primary key,
	username varchar,
	password_digest varchar,
	"dataFiles" character varying[] default '{}'::character varying[],
	created_at timestamp(6) not null,
	updated_at timestamp(6) not null,
	role_id bigint
		constraint fk_rails_642f17018b
			references public.roles,
	account_id bigint
		constraint fk_rails_61ac11da2b
			references public.accounts
);

alter table public.users owner to gapp_db;

create index index_users_on_role_id
	on public.users (role_id);

create index index_users_on_account_id
	on public.users (account_id);

create table public.tasks
(
	id bigserial
		constraint tasks_pkey
			primary key,
	name varchar,
	user_id bigint not null
		constraint fk_rails_4d2a9e4d7e
			references public.users,
	analyses_id bigint
		constraint fk_rails_695c36a3bd
			references public.analyses,
	created_at timestamp(6) not null,
	updated_at timestamp(6) not null,
	app_id bigint not null
		constraint fk_rails_cd4c710dff
			references public.apps,
	task_id varchar,
	status varchar
);

alter table public.tasks owner to gapp_db;

create index index_tasks_on_user_id
	on public.tasks (user_id);

create index index_tasks_on_analyses_id
	on public.tasks (analyses_id);

create index index_tasks_on_app_id
	on public.tasks (app_id);

create unique index index_accounts_on_email
	on public.accounts (email);

create unique index index_accounts_on_reset_password_token
	on public.accounts (reset_password_token);

create unique index index_accounts_on_confirmation_token
	on public.accounts (confirmation_token);

create unique index index_accounts_on_unlock_token
	on public.accounts (unlock_token);

create index index_accounts_on_invited_by_type_and_invited_by_id
	on public.accounts (invited_by_type, invited_by_id);

create unique index index_accounts_on_invitation_token
	on public.accounts (invitation_token);

create index index_accounts_on_invited_by_id
	on public.accounts (invited_by_id);

create table public.account_roles
(
	id bigserial
		constraint account_roles_pkey
			primary key,
	name varchar,
	resource_type varchar,
	resource_id bigint,
	created_at timestamp(6) not null,
	updated_at timestamp(6) not null
);

alter table public.account_roles owner to gapp_db;

create index index_account_roles_on_resource_type_and_resource_id
	on public.account_roles (resource_type, resource_id);

create index index_account_roles_on_name_and_resource_type_and_resource_id
	on public.account_roles (name, resource_type, resource_id);

create table public.accounts_account_roles
(
	account_id bigint,
	account_role_id bigint
);

alter table public.accounts_account_roles owner to gapp_db;

create index index_accounts_account_roles_on_account_id
	on public.accounts_account_roles (account_id);

create index index_accounts_account_roles_on_account_role_id
	on public.accounts_account_roles (account_role_id);

create index index_accounts_account_roles_on_account_id_and_account_role_id
	on public.accounts_account_roles (account_id, account_role_id);

