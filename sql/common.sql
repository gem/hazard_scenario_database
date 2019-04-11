--
-- Common elements for all Challenge Fund Database Schemas
-- Hazard enumeration (Based on discussions with Stuart Fraser, GFDRR)
-- License table
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.16
-- Dumped by pg_dump version 9.5.16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: cf_common; Type: SCHEMA; Schema: -; Owner: hazardcontrib
--

CREATE SCHEMA cf_common;


ALTER SCHEMA cf_common OWNER TO hazardcontrib;

--
-- Name: SCHEMA cf_common; Type: COMMENT; Schema: -; Owner: hazardcontrib
--

COMMENT ON SCHEMA cf_common IS 'Common elements for all Challenge Fund Database Schemas';


SET default_with_oids = false;

--
-- Name: hazard_type; Type: TABLE; Schema: cf_common; Owner: hazardcontrib
--

CREATE TABLE cf_common.hazard_type (
    code character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE cf_common.hazard_type OWNER TO hazardcontrib;

--
-- Name: TABLE hazard_type; Type: COMMENT; Schema: cf_common; Owner: hazardcontrib
--

COMMENT ON TABLE cf_common.hazard_type IS 'Valid Process types by Hazard type';


--
-- Name: license; Type: TABLE; Schema: cf_common; Owner: hazardcontrib
--

CREATE TABLE cf_common.license (
    id integer NOT NULL,
    code character varying NOT NULL,
    name character varying NOT NULL,
    notes text,
    url character varying NOT NULL
);


ALTER TABLE cf_common.license OWNER TO hazardcontrib;

--
-- Name: TABLE license; Type: COMMENT; Schema: cf_common; Owner: hazardcontrib
--

COMMENT ON TABLE cf_common.license IS 'List of supported licenses';


--
-- Name: license_id_seq; Type: SEQUENCE; Schema: cf_common; Owner: hazardcontrib
--

CREATE SEQUENCE cf_common.license_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cf_common.license_id_seq OWNER TO hazardcontrib;

--
-- Name: license_id_seq; Type: SEQUENCE OWNED BY; Schema: cf_common; Owner: hazardcontrib
--

ALTER SEQUENCE cf_common.license_id_seq OWNED BY cf_common.license.id;


--
-- Name: process_type; Type: TABLE; Schema: cf_common; Owner: hazardcontrib
--

CREATE TABLE cf_common.process_type (
    code character varying NOT NULL,
    hazard_code character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE cf_common.process_type OWNER TO hazardcontrib;

--
-- Name: id; Type: DEFAULT; Schema: cf_common; Owner: hazardcontrib
--

ALTER TABLE ONLY cf_common.license ALTER COLUMN id SET DEFAULT nextval('cf_common.license_id_seq'::regclass);


--
-- Data for Name: hazard_type; Type: TABLE DATA; Schema: cf_common; Owner: hazardcontrib
--

COPY cf_common.hazard_type (code, name) FROM stdin;
CS	Convective Storm
EQ	Earthquake
TS	Tsunami
VO	Volcanic
CF	Coastal Flood
FL	Flood
LS	Landslide
WI	Strong Wind
ET	Extreme Temperature
DR	Drought
WF	Wildfire
MH	Multi-Hazard
\.


--
-- Data for Name: license; Type: TABLE DATA; Schema: cf_common; Owner: hazardcontrib
--

COPY cf_common.license (id, code, name, notes, url) FROM stdin;
7	CC0	Creative Commons CCZero (CC0)	Dedicate to the Public Domain (all rights waived)	https://creativecommons.org/publicdomain/zero/1.0/
8	PDDL	Open Data Commons Public Domain Dedication and Licence (PDDL)	Dedicate to the Public Domain (all rights waived)	https://opendatacommons.org/licenses/pddl/index.html
9	CC-BY-4.0	Creative Commons Attribution 4.0 (CC-BY-4.0)	\N	https://creativecommons.org/licenses/by/4.0/
10	ODC-BY	Open Data Commons Attribution License(ODC-BY)	Attribution for data(bases)	https://opendatacommons.org/licenses/by/summary/
11	CC-BY-SA-4.0	Creative Commons Attribution Share-Alike 4.0 (CC-BY-SA-4.0)	\N	http://creativecommons.org/licenses/by-sa/4.0/
12	ODbL	Open Data Commons Open Database License (ODbL)	Attribution-ShareAlike for data(bases)	https://opendatacommons.org/licenses/odbl/summary/
\.


--
-- Name: license_id_seq; Type: SEQUENCE SET; Schema: cf_common; Owner: hazardcontrib
--

SELECT pg_catalog.setval('cf_common.license_id_seq', 12, true);


--
-- Data for Name: process_type; Type: TABLE DATA; Schema: cf_common; Owner: hazardcontrib
--

COPY cf_common.process_type (code, hazard_code, name) FROM stdin;
QLI	EQ	Liquefaction
QGM	EQ	Ground Motion
Q1R	EQ	Primary Rupture
Q2R	EQ	Secondary Rupture
TSI	TS	Tsunami
VAF	VO	Ashfall
VLH	VO	Lahar
VPF	VO	Pyroclastic Flow
VBL	VO	Ballistics
VLV	VO	Lava
VFH	VO	Proximal hazards
FSS	CF	Storm Surge
FCF	CF	Coastal Flood
FFF	FL	Fluvial Flood
FPF	FL	Pluvial Flood
LAV	LS	Snow Avalanche
LSL	LS	Landslide (general)
TCY	WI	Tropical cyclone
ETC	WI	Extratropical cyclone
EHT	ET	Extreme heat
ECD	ET	Extreme cold
DTS	DR	Socio-economic Drought
DTM	DR	Meteorological Drought
DTH	DR	Hydrological Drought
DTA	DR	Agricultural Drought
WFI	WF	Wildfire
TOR	CS	Tornado
\.


--
-- Name: hazard_type_pkey; Type: CONSTRAINT; Schema: cf_common; Owner: hazardcontrib
--

ALTER TABLE ONLY cf_common.hazard_type
    ADD CONSTRAINT hazard_type_pkey PRIMARY KEY (code);


--
-- Name: license_pkey; Type: CONSTRAINT; Schema: cf_common; Owner: hazardcontrib
--

ALTER TABLE ONLY cf_common.license
    ADD CONSTRAINT license_pkey PRIMARY KEY (id);


--
-- Name: process_type_pkey; Type: CONSTRAINT; Schema: cf_common; Owner: hazardcontrib
--

ALTER TABLE ONLY cf_common.process_type
    ADD CONSTRAINT process_type_pkey PRIMARY KEY (code);


--
-- Name: process_type_hazard_code_fkey; Type: FK CONSTRAINT; Schema: cf_common; Owner: hazardcontrib
--

ALTER TABLE ONLY cf_common.process_type
    ADD CONSTRAINT process_type_hazard_code_fkey FOREIGN KEY (hazard_code) REFERENCES cf_common.hazard_type(code);


--
-- Name: SCHEMA cf_common; Type: ACL; Schema: -; Owner: hazardcontrib
--

REVOKE ALL ON SCHEMA cf_common FROM PUBLIC;
REVOKE ALL ON SCHEMA cf_common FROM hazardcontrib;
GRANT ALL ON SCHEMA cf_common TO hazardcontrib;
GRANT USAGE ON SCHEMA cf_common TO hazardviewer;


--
-- Name: TABLE hazard_type; Type: ACL; Schema: cf_common; Owner: hazardcontrib
--

REVOKE ALL ON TABLE cf_common.hazard_type FROM PUBLIC;
REVOKE ALL ON TABLE cf_common.hazard_type FROM hazardcontrib;
GRANT ALL ON TABLE cf_common.hazard_type TO hazardcontrib;
GRANT SELECT ON TABLE cf_common.hazard_type TO hazardviewer;


--
-- Name: TABLE license; Type: ACL; Schema: cf_common; Owner: hazardcontrib
--

REVOKE ALL ON TABLE cf_common.license FROM PUBLIC;
REVOKE ALL ON TABLE cf_common.license FROM hazardcontrib;
GRANT ALL ON TABLE cf_common.license TO hazardcontrib;
GRANT SELECT ON TABLE cf_common.license TO hazardviewer;


--
-- Name: TABLE process_type; Type: ACL; Schema: cf_common; Owner: hazardcontrib
--

REVOKE ALL ON TABLE cf_common.process_type FROM PUBLIC;
REVOKE ALL ON TABLE cf_common.process_type FROM hazardcontrib;
GRANT ALL ON TABLE cf_common.process_type TO hazardcontrib;
GRANT SELECT ON TABLE cf_common.process_type TO hazardviewer;


--
-- PostgreSQL database dump complete
--

