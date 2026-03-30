-- ═══════════════════════════════════════════════════════════════
-- RESONANCE Speaker Archive — Supabase Database Setup
-- Run this entire file in: Supabase Dashboard → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════


-- ───────────────────────────────────────────
-- 1. SPEAKERS TABLE
-- ───────────────────────────────────────────
create table if not exists speakers (
  id          bigint primary key generated always as identity,
  brand       text not null,
  model       text not null,
  type        text not null default 'Full-Range',
  size        text,
  tagline     text,
  impedance   text,
  power       text,
  sensitivity text,
  freq_range  text,
  fs_hz       numeric,
  qts         numeric,
  vas         text,
  xmax        text,
  weight      text,
  enclosures  text[]  default '{}',   -- stored as a Postgres array
  color       text    default '#e8ff47',
  accent      text    default '#e8ff47',
  custom_data jsonb   default '{}',   -- holds any custom field values
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- Auto-update updated_at on every row change
create or replace function update_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists speakers_updated_at on speakers;
create trigger speakers_updated_at
  before update on speakers
  for each row execute function update_updated_at();


-- ───────────────────────────────────────────
-- 2. CUSTOM FIELDS TABLE
-- ───────────────────────────────────────────
create table if not exists custom_fields (
  id          bigint primary key generated always as identity,
  key         text not null unique,
  label       text not null,
  type        text not null default 'text',  -- text | number | textarea | select
  placeholder text default '',
  section     text default 'Extra',          -- Identity | Electrical | Thiele–Small | Extra
  options     text[] default '{}',           -- only used when type = 'select'
  sort_order  integer default 0,
  created_at  timestamptz default now()
);


-- ───────────────────────────────────────────
-- 3. BUILT-IN FIELD OVERRIDES TABLE
-- ───────────────────────────────────────────
create table if not exists builtin_overrides (
  key         text primary key,   -- matches a key from BUILT_IN_FIELDS in the app
  label       text,
  placeholder text,
  section     text,
  updated_at  timestamptz default now()
);


-- ───────────────────────────────────────────
-- 4. ROW LEVEL SECURITY
-- Public can read speakers (gallery visible to anyone).
-- Only authenticated users can write (your admin login).
-- ───────────────────────────────────────────
alter table speakers          enable row level security;
alter table custom_fields     enable row level security;
alter table builtin_overrides enable row level security;

-- Speakers: anyone can read
create policy "Public read speakers"
  on speakers for select using (true);

-- Speakers: only authenticated users can insert / update / delete
create policy "Auth write speakers"
  on speakers for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- Custom fields: anyone can read (needed to render public gallery correctly)
create policy "Public read custom_fields"
  on custom_fields for select using (true);

create policy "Auth write custom_fields"
  on custom_fields for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- Builtin overrides: same pattern
create policy "Public read builtin_overrides"
  on builtin_overrides for select using (true);

create policy "Auth write builtin_overrides"
  on builtin_overrides for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');


-- ───────────────────────────────────────────
-- 5. SEED DATA — the 12 default speakers
-- ───────────────────────────────────────────
insert into speakers
  (brand, model, type, size, tagline, impedance, power, sensitivity, freq_range,
   fs_hz, qts, vas, xmax, weight, enclosures, color, accent)
values
  ('Scanspeak',  'Revelator 15W/8530K01', 'Full-Range', '6"',   'Reference midwoofer with titanium-coated cone and symmetrical drive motor.',          '8Ω',  '90W RMS',   '87 dB',   '32Hz – 5kHz',    32,  0.34, '18.5L', '7mm',  '1.2kg',  ARRAY['Sealed','Bass Reflex','Transmission Line'],             '#4a9eff', '#64b4ff'),
  ('Dayton Audio','RSS390HF-4',           'Subwoofer',  '15"',  'High-excursion subwoofer engineered for infrasonic bass reproduction.',                 '4Ω',  '700W RMS',  '86.5 dB', '16Hz – 250Hz',   16,  0.28, '240L',  '31mm', '11.8kg', ARRAY['Sealed','Ported','Isobaric','Bandpass 4th Order'],       '#ff6b35', '#ff8c5a'),
  ('Seas',       'T35 H1189-06',          'Tweeter',    '1"',   'Fabric dome tweeter with ferrofluid cooling and extended ultra-HF response.',           '6Ω',  '130W RMS',  '91 dB',   '1.2kHz – 40kHz', 550, 0.62, '0.06L', '2mm',  '0.35kg', ARRAY['Waveguide','Open Baffle'],                              '#64b4ff', '#89caff'),
  ('Faital Pro', '8FE200',                'Midrange',   '8"',   'Professional midrange with neodymium motor for high-SPL applications.',                 '8Ω',  '200W RMS',  '97 dB',   '80Hz – 5kHz',    85,  0.38, '26L',   '5mm',  '2.8kg',  ARRAY['Horn','Sealed','Midrange Chamber'],                      '#b464ff', '#c882ff'),
  ('Beyma',      '12CX300Nd',             'Coaxial',    '12"',  'Integrated coaxial driver with neodymium compression driver at center phase plug.',     '8Ω',  '300W RMS',  '96 dB',   '50Hz – 20kHz',   55,  0.32, '65L',   '8mm',  '6.2kg',  ARRAY['Bass Reflex','Horn Loaded'],                            '#ffc832', '#ffd55a'),
  ('JBL',        'D2415K',                'Tweeter',    '1.5"', 'Dual-diaphragm annular compression driver for ultra-high output horn systems.',         '8Ω',  '100W RMS',  '113 dB',  '1kHz – 25kHz',   350, 0.80, '0.02L', '1.5mm','0.82kg', ARRAY['Horn Only'],                                            '#e8ff47', '#f0ff70'),
  ('Eminence',   'Kappa Pro 15A',         'Full-Range', '15"',  'High-power professional woofer with extended frequency range and robust motor.',         '4Ω',  '500W RMS',  '100 dB',  '40Hz – 4kHz',    40,  0.33, '180L',  '9mm',  '7.4kg',  ARRAY['Bass Reflex','Horn','Sealed'],                          '#32ffb4', '#55ffcc'),
  ('Peerless',   'SLS-830669',            'Subwoofer',  '12"',  'Long-throw subwoofer with vented aluminum pole piece for maximum excursion.',            '4Ω',  '250W RMS',  '83 dB',   '22Hz – 350Hz',   22,  0.22, '125L',  '15mm', '5.8kg',  ARRAY['Sealed','Ported','Bandpass 6th Order'],                 '#ff6b35', '#ff8c5a'),
  ('Audax',      'HDA13D34H',             'Midrange',   '5"',   'Cone midrange with treated paper cone and copper demodulation ring.',                    '6Ω',  '50W RMS',   '89 dB',   '150Hz – 7kHz',   160, 0.70, '3.4L',  '3.5mm','0.65kg', ARRAY['Sealed','Acoustic Suspension'],                        '#b464ff', '#c882ff'),
  ('RCF',        'MB10N351',              'Line Array', '10"',  'Line array element driver with controlled directivity and neodymium magnet system.',     '8Ω',  '350W RMS',  '98 dB',   '70Hz – 3kHz',    72,  0.28, '58L',   '12mm', '4.9kg',  ARRAY['Bandpass','Ported','Manifold Load'],                    '#32ffb4', '#55ffcc'),
  ('Wavecor',    'WF182BD06',             'Full-Range', '7"',   'Audiophile-grade midwoofer with black aluminum cone and dual-layer voice coil.',         '6Ω',  '120W RMS',  '88 dB',   '35Hz – 5kHz',    35,  0.35, '22L',   '8mm',  '1.9kg',  ARRAY['Bass Reflex','Sealed','TQWT'],                          '#4a9eff', '#64b4ff'),
  ('Beyma',      '21SW1600Nd',            'Subwoofer',  '21"',  'Extreme SPL 21-inch subwoofer for large-venue professional sound reinforcement.',        '4Ω',  '1600W RMS', '98 dB',   '14Hz – 200Hz',   14,  0.20, '610L',  '42mm', '28kg',   ARRAY['Ported','Horn Loaded','Tapped Horn'],                   '#ff6b35', '#ff8c5a')
on conflict do nothing;


-- ───────────────────────────────────────────
-- Done! Check your data:
-- ───────────────────────────────────────────
-- select count(*) from speakers;   -- should return 12
-- select brand, model from speakers order by id;
