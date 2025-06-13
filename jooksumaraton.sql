--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

-- Started on 2024-05-05 22:46:29

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS public;


--
-- TOC entry 4954 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 237 (class 1255 OID 17995)
-- Name: f_jooksjatulemused(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_jooksjatulemused(jooksja_id integer) RETURNS TABLE(tulemuse_id integer, stardinumber integer, stardiaeg timestamp with time zone, finishiaeg timestamp with time zone, koht integer, koht_vanuseklassis integer, distants numeric, stardigrupp character, vanuseklass character, maratoni_nimi character varying, toimumiskuupaev date)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select
		t.id,
		t.stardinumber,
		t.stardiaeg,
		t.finishiaeg,
		t.koht,
		t.koht_vanuseklassis,
		t.distants,
		t.stardigrupp,
		t.vanuseklass,
		m.nimi,
		m.toimumiskuupaev
	from tulemused t join maraton m on t.maraton_id = m.id
	where t.jaaksja_id = jooksja_id;
end; $$;


--
-- TOC entry 238 (class 1255 OID 17996)
-- Name: f_klubiliikmed(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_klubiliikmed(klubi_nimi character varying) RETURNS TABLE(id integer, eesnimi character varying, perenimi character varying, roll text, email character varying, synniaeg date, haridustase character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN QUERY
   SELECT
       j.id,
       j.eesnimi,
       j.perenimi,
       'Liige' AS roll,
       NULL AS email,  -- Liikmetel ei pruugi olla e-maili andmeid tabelis
       j.synniaeg,
       NULL AS haridustase  -- Liikmetel ei ole haridustase määratud
   FROM
       jooksjad j
       JOIN klubid k ON j.klubi = k.id
   WHERE
       k.nimi = klubi_nimi
   UNION ALL
   SELECT
       t.id,
       t.eesnimi,
       t.perenimi,
       'Treener' AS roll,
       t.email,
       t.synniaeg,
       t.haridustase
   FROM
       treenerid t
       JOIN klubid k ON t.klubi = k.id
   WHERE
       k.nimi = klubi_nimi;
END; $$;


--
-- TOC entry 240 (class 1255 OID 17998)
-- Name: sp_uus_klubi(character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_uus_klubi(IN klubi_nimi character varying, IN klubi_asukoht character varying)
    LANGUAGE plpgsql
    AS $$
begin
	insert into klubid (nimi, asukoht) values (klubi_nimi, klubi_asukoht);
	raise notice 'Klubi on lisatud: %', klubi_nimi;
end;
$$;


--
-- TOC entry 239 (class 1255 OID 17997)
-- Name: sp_uus_maratonide_sari(character varying, integer, date, date, numeric); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_uus_maratonide_sari(IN t_nimi character varying, IN t_peasponsori_id integer, IN t_sponsori_lepingu_algus date, IN t_sponsori_lepingu_lopp date, IN t_toetussumma numeric)
    LANGUAGE plpgsql
    AS $$
   DECLARE 
   arv integer:=0; 
BEGIN
   SELECT count(*) INTO arv FROM peasponsorid WHERE id=t_peasponsori_id;
   IF arv=0 THEN
       RAISE NOTICE 'Turniiri ei lisatud, sest ei ole sellist sponsorit';
   END IF;
INSERT INTO maratonide_sari(nimi, peasponsor_id, sponsori_lepingu_algus, sponsori_lepingu_lopp, toetussumma) VALUES (t_nimi, t_peasponsori_id, t_sponsori_lepingu_algus, t_sponsori_lepingu_lopp, t_toetussumma);
RAISE NOTICE 'Lisati maratonide sari nimega %, toetussummaga: %.', t_nimi, t_toetussumma;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 17870)
-- Name: auhinnad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auhinnad (
    id integer NOT NULL,
    nimetus character varying(50) NOT NULL,
    vaartus integer NOT NULL,
    sponsori_panus integer
);


--
-- TOC entry 216 (class 1259 OID 17873)
-- Name: auhinnad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auhinnad ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.auhinnad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 217 (class 1259 OID 17874)
-- Name: jooksjad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jooksjad (
    id integer NOT NULL,
    isikukood character varying(18) NOT NULL,
    elukoha_riik character varying(50) NOT NULL,
    eesnimi character varying(70) NOT NULL,
    perenimi character varying(70) NOT NULL,
    klubi integer,
    synniaeg date NOT NULL,
    sugu character(1) NOT NULL
);


--
-- TOC entry 218 (class 1259 OID 17877)
-- Name: jooksjad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.jooksjad ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.jooksjad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 219 (class 1259 OID 17878)
-- Name: klubid; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.klubid (
    id integer NOT NULL,
    nimi character varying(70) NOT NULL,
    asukoht character varying(50) NOT NULL
);


--
-- TOC entry 220 (class 1259 OID 17881)
-- Name: klubid_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.klubid ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.klubid_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 17882)
-- Name: maraton; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maraton (
    id integer NOT NULL,
    nimi character varying(70) NOT NULL,
    toimumiskuupaev date NOT NULL,
    raja_id integer NOT NULL,
    maratonide_sari_id integer NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 17885)
-- Name: maraton_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.maraton ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.maraton_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 17886)
-- Name: maratonide_sari; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maratonide_sari (
    id integer NOT NULL,
    nimi character varying(50) NOT NULL,
    peasponsor_id integer NOT NULL,
    sponsori_lepingu_algus date NOT NULL,
    sponsori_lepingu_lopp date NOT NULL,
    toetussumma numeric(10,0) NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 17889)
-- Name: maratonide_sari_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.maratonide_sari ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.maratonide_sari_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 17890)
-- Name: peasponsorid; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.peasponsorid (
    id integer NOT NULL,
    sponsori_nimi character varying(50) NOT NULL,
    email character varying(320),
    riik character varying(50) NOT NULL
);


--
-- TOC entry 226 (class 1259 OID 17893)
-- Name: peasponsorid_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.peasponsorid ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.peasponsorid_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 227 (class 1259 OID 17894)
-- Name: rajad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rajad (
    id integer NOT NULL,
    nimi character varying(50) NOT NULL,
    asukoht character varying(50) NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 17897)
-- Name: rajad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.rajad ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rajad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 17898)
-- Name: treenerid; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.treenerid (
    id integer NOT NULL,
    klubi integer NOT NULL,
    eesnimi character varying(70) NOT NULL,
    perenimi character varying(70) NOT NULL,
    email character varying(320) NOT NULL,
    synniaeg date NOT NULL,
    haridustase character varying(30)
);


--
-- TOC entry 230 (class 1259 OID 17901)
-- Name: treenerid_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.treenerid ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.treenerid_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 17902)
-- Name: tulemuse_auhinnad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tulemuse_auhinnad (
    id integer NOT NULL,
    tulemus_id integer NOT NULL,
    auhind_id integer NOT NULL
);


--
-- TOC entry 232 (class 1259 OID 17905)
-- Name: tulemuse_auhinnad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tulemuse_auhinnad ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tulemuse_auhinnad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 17906)
-- Name: tulemused; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tulemused (
    id integer NOT NULL,
    jaaksja_id integer NOT NULL,
    maraton_id integer NOT NULL,
    stardinumber integer NOT NULL,
    stardiaeg timestamp with time zone NOT NULL,
    finishiaeg timestamp with time zone,
    koht integer,
    koht_vanuseklassis integer,
    distants numeric(10,0) NOT NULL,
    stardigrupp character(1),
    vanuseklass character(3) NOT NULL
);


--
-- TOC entry 234 (class 1259 OID 17909)
-- Name: tulemused_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tulemused ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tulemused_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 17985)
-- Name: v_top3_distants; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_top3_distants AS
 SELECT (((j.eesnimi)::text || ' '::text) || (j.perenimi)::text) AS nimi,
    sum(t.distants) AS "Distants kokku"
   FROM (public.jooksjad j
     JOIN public.tulemused t ON ((j.id = t.jaaksja_id)))
  GROUP BY j.eesnimi, j.perenimi
  ORDER BY (sum(t.distants)) DESC
 LIMIT 3;


--
-- TOC entry 236 (class 1259 OID 17990)
-- Name: v_võidetudauhinnad; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."v_võidetudauhinnad" AS
 SELECT (((j.perenimi)::text || ', '::text) || (j.eesnimi)::text) AS nimi,
    sum(a.vaartus) AS "Võidud kokku"
   FROM (((public.jooksjad j
     JOIN public.tulemused t ON ((j.id = t.jaaksja_id)))
     JOIN public.tulemuse_auhinnad ta ON ((t.id = ta.tulemus_id)))
     JOIN public.auhinnad a ON ((ta.auhind_id = a.id)))
  GROUP BY j.eesnimi, j.perenimi
  ORDER BY (sum(a.vaartus)) DESC;


--
-- TOC entry 4929 (class 0 OID 17870)
-- Dependencies: 215
-- Data for Name: auhinnad; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.auhinnad OVERRIDING SYSTEM VALUE VALUES (1, 'Medal', 20, 15);
INSERT INTO public.auhinnad OVERRIDING SYSTEM VALUE VALUES (2, 'Diplom', 2, 0);
INSERT INTO public.auhinnad OVERRIDING SYSTEM VALUE VALUES (3, 'Medal', 15, 5);
INSERT INTO public.auhinnad OVERRIDING SYSTEM VALUE VALUES (4, 'Rahaline auhind 3000€', 3000, 3000);


--
-- TOC entry 4931 (class 0 OID 17874)
-- Dependencies: 217
-- Data for Name: jooksjad; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.jooksjad OVERRIDING SYSTEM VALUE VALUES (5, '50211192736', 'Eesti', 'Markus', 'Lemberg', 2, '2002-11-19', 'm');
INSERT INTO public.jooksjad OVERRIDING SYSTEM VALUE VALUES (6, '50905132774', 'Eesti', 'Kristjan', 'Säärits', 1, '2009-05-13', 'm');
INSERT INTO public.jooksjad OVERRIDING SYSTEM VALUE VALUES (7, '39703121408', 'Eesti', 'Aksel', 'Kaasik', 2, '1997-03-12', 'm');
INSERT INTO public.jooksjad OVERRIDING SYSTEM VALUE VALUES (8, '4319446807', 'Soome', 'Aili', 'Järvelä', 4, '1985-11-05', 'n');


--
-- TOC entry 4933 (class 0 OID 17878)
-- Dependencies: 219
-- Data for Name: klubid; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.klubid OVERRIDING SYSTEM VALUE VALUES (1, 'Tartu välejalad', 'Tartu');
INSERT INTO public.klubid OVERRIDING SYSTEM VALUE VALUES (2, 'Jooksikud', 'Paide');
INSERT INTO public.klubid OVERRIDING SYSTEM VALUE VALUES (3, 'Kõrsikud', 'Võru');
INSERT INTO public.klubid OVERRIDING SYSTEM VALUE VALUES (4, 'Turun juoksijat', 'Turu');
INSERT INTO public.klubid OVERRIDING SYSTEM VALUE VALUES (5, 'Pärnu meistrid', 'Pärnu');


--
-- TOC entry 4935 (class 0 OID 17882)
-- Dependencies: 221
-- Data for Name: maraton; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.maraton OVERRIDING SYSTEM VALUE VALUES (2, '41. Tartu Maastikumaraton', '2023-05-11', 1, 2);
INSERT INTO public.maraton OVERRIDING SYSTEM VALUE VALUES (3, '32. Paavo Nurmi maraton', '2023-08-14', 2, 3);
INSERT INTO public.maraton OVERRIDING SYSTEM VALUE VALUES (4, 'Tallinna maraton 2023', '2023-08-06', 3, 4);
INSERT INTO public.maraton OVERRIDING SYSTEM VALUE VALUES (5, '9. Kihnu maraton', '2023-06-04', 4, 5);


--
-- TOC entry 4937 (class 0 OID 17886)
-- Dependencies: 223
-- Data for Name: maratonide_sari; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.maratonide_sari OVERRIDING SYSTEM VALUE VALUES (2, 'Tartu Maraton', 1, '2018-01-01', '2028-01-01', 900000);
INSERT INTO public.maratonide_sari OVERRIDING SYSTEM VALUE VALUES (3, 'Paavo Nurmi maraton', 2, '2021-03-02', '2025-12-31', 8500000);
INSERT INTO public.maratonide_sari OVERRIDING SYSTEM VALUE VALUES (4, 'Eesti linnajooksud', 3, '2023-01-01', '2026-12-31', 150000);
INSERT INTO public.maratonide_sari OVERRIDING SYSTEM VALUE VALUES (5, 'Kihnu maraton', 3, '2017-01-01', '2025-01-01', 81000);
INSERT INTO public.maratonide_sari OVERRIDING SYSTEM VALUE VALUES (6, 'Pärnu maraton', 2, '2019-02-22', '2026-12-31', 100000);


--
-- TOC entry 4939 (class 0 OID 17890)
-- Dependencies: 225
-- Data for Name: peasponsorid; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.peasponsorid OVERRIDING SYSTEM VALUE VALUES (1, 'Salvest', 'salvest@salvest.ee', 'Eesti');
INSERT INTO public.peasponsorid OVERRIDING SYSTEM VALUE VALUES (2, 'Intersport', 'sport@intersport.ch', 'Šveits');
INSERT INTO public.peasponsorid OVERRIDING SYSTEM VALUE VALUES (3, 'Rimi', 'sport@rimi.ee', 'Eesti');
INSERT INTO public.peasponsorid OVERRIDING SYSTEM VALUE VALUES (4, 'Värska', 'originaal@varska.ee', 'Eesti');


--
-- TOC entry 4941 (class 0 OID 17894)
-- Dependencies: 227
-- Data for Name: rajad; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.rajad OVERRIDING SYSTEM VALUE VALUES (1, 'Tartu Maratoni Rada', 'Tartumaa');
INSERT INTO public.rajad OVERRIDING SYSTEM VALUE VALUES (2, 'Turu linna ümbrus', 'Päris-Soome maakond');
INSERT INTO public.rajad OVERRIDING SYSTEM VALUE VALUES (3, 'Tallinna linn', 'Harjumaa');
INSERT INTO public.rajad OVERRIDING SYSTEM VALUE VALUES (4, 'Kihnu saar', 'Saaremaa');


--
-- TOC entry 4943 (class 0 OID 17898)
-- Dependencies: 229
-- Data for Name: treenerid; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.treenerid OVERRIDING SYSTEM VALUE VALUES (5, 2, 'Urmas', 'Jurmas', 'urmas.jurmas@hot.ee', '1966-03-17', 'bakalaureuse');
INSERT INTO public.treenerid OVERRIDING SYSTEM VALUE VALUES (6, 4, 'Marika', 'Halonen', 'marika.hal@gmail.com', '1995-08-04', 'magister');
INSERT INTO public.treenerid OVERRIDING SYSTEM VALUE VALUES (7, 1, 'Artur', 'Kruus', 'arturkruus@gmail.com', '1989-12-03', 'kesk');
INSERT INTO public.treenerid OVERRIDING SYSTEM VALUE VALUES (8, 1, 'Aivar', 'Põld', 'aivar@treener.ee', '1974-04-27', 'magister');


--
-- TOC entry 4945 (class 0 OID 17902)
-- Dependencies: 231
-- Data for Name: tulemuse_auhinnad; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tulemuse_auhinnad OVERRIDING SYSTEM VALUE VALUES (1, 4, 3);
INSERT INTO public.tulemuse_auhinnad OVERRIDING SYSTEM VALUE VALUES (2, 3, 1);
INSERT INTO public.tulemuse_auhinnad OVERRIDING SYSTEM VALUE VALUES (4, 5, 4);
INSERT INTO public.tulemuse_auhinnad OVERRIDING SYSTEM VALUE VALUES (5, 5, 3);
INSERT INTO public.tulemuse_auhinnad OVERRIDING SYSTEM VALUE VALUES (6, 6, 2);


--
-- TOC entry 4947 (class 0 OID 17906)
-- Dependencies: 233
-- Data for Name: tulemused; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tulemused OVERRIDING SYSTEM VALUE VALUES (3, 5, 2, 2068, '2023-05-02 10:15:00+03', '2023-05-02 12:36:53+03', 1825, 371, 21, 'E', 'M21');
INSERT INTO public.tulemused OVERRIDING SYSTEM VALUE VALUES (4, 8, 3, 3217, '2023-08-14 10:30:00+03', '2023-08-14 16:20:00+03', 2631, 394, 42, 'E', 'N35');
INSERT INTO public.tulemused OVERRIDING SYSTEM VALUE VALUES (5, 6, 4, 311, '2023-09-06 10:00:00+03', '2023-09-06 13:03:00+03', 160, 1, 42, 'B', 'M17');
INSERT INTO public.tulemused OVERRIDING SYSTEM VALUE VALUES (6, 7, 5, 79, '2023-06-04 11:00:00+03', '2023-09-06 12:43:00+03', 7, 2, 21, NULL, 'M20');


--
-- TOC entry 4955 (class 0 OID 0)
-- Dependencies: 216
-- Name: auhinnad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auhinnad_id_seq', 4, true);


--
-- TOC entry 4956 (class 0 OID 0)
-- Dependencies: 218
-- Name: jooksjad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jooksjad_id_seq', 8, true);


--
-- TOC entry 4957 (class 0 OID 0)
-- Dependencies: 220
-- Name: klubid_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.klubid_id_seq', 5, true);


--
-- TOC entry 4958 (class 0 OID 0)
-- Dependencies: 222
-- Name: maraton_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.maraton_id_seq', 5, true);


--
-- TOC entry 4959 (class 0 OID 0)
-- Dependencies: 224
-- Name: maratonide_sari_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.maratonide_sari_id_seq', 6, true);


--
-- TOC entry 4960 (class 0 OID 0)
-- Dependencies: 226
-- Name: peasponsorid_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.peasponsorid_id_seq', 4, true);


--
-- TOC entry 4961 (class 0 OID 0)
-- Dependencies: 228
-- Name: rajad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rajad_id_seq', 4, true);


--
-- TOC entry 4962 (class 0 OID 0)
-- Dependencies: 230
-- Name: treenerid_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.treenerid_id_seq', 8, true);


--
-- TOC entry 4963 (class 0 OID 0)
-- Dependencies: 232
-- Name: tulemuse_auhinnad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tulemuse_auhinnad_id_seq', 6, true);


--
-- TOC entry 4964 (class 0 OID 0)
-- Dependencies: 234
-- Name: tulemused_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tulemused_id_seq', 6, true);


--
-- TOC entry 4746 (class 2606 OID 17911)
-- Name: auhinnad auhinnad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auhinnad
    ADD CONSTRAINT auhinnad_pkey PRIMARY KEY (id);


--
-- TOC entry 4748 (class 2606 OID 17913)
-- Name: jooksjad jooksjad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jooksjad
    ADD CONSTRAINT jooksjad_pkey PRIMARY KEY (id);


--
-- TOC entry 4750 (class 2606 OID 17915)
-- Name: klubid klubid_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.klubid
    ADD CONSTRAINT klubid_pkey PRIMARY KEY (id);


--
-- TOC entry 4752 (class 2606 OID 17917)
-- Name: maraton maraton_nimi_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maraton
    ADD CONSTRAINT maraton_nimi_key UNIQUE (nimi);


--
-- TOC entry 4754 (class 2606 OID 17919)
-- Name: maraton maraton_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maraton
    ADD CONSTRAINT maraton_pkey PRIMARY KEY (id);


--
-- TOC entry 4756 (class 2606 OID 17921)
-- Name: maratonide_sari maratonide_sari_nimi_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maratonide_sari
    ADD CONSTRAINT maratonide_sari_nimi_key UNIQUE (nimi);


--
-- TOC entry 4758 (class 2606 OID 17923)
-- Name: maratonide_sari maratonide_sari_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maratonide_sari
    ADD CONSTRAINT maratonide_sari_pkey PRIMARY KEY (id);


--
-- TOC entry 4760 (class 2606 OID 17925)
-- Name: peasponsorid peasponsorid_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.peasponsorid
    ADD CONSTRAINT peasponsorid_pkey PRIMARY KEY (id);


--
-- TOC entry 4762 (class 2606 OID 17927)
-- Name: peasponsorid peasponsorid_sponsori_nimi_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.peasponsorid
    ADD CONSTRAINT peasponsorid_sponsori_nimi_key UNIQUE (sponsori_nimi);


--
-- TOC entry 4764 (class 2606 OID 17929)
-- Name: rajad rajad_nimi_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rajad
    ADD CONSTRAINT rajad_nimi_key UNIQUE (nimi);


--
-- TOC entry 4766 (class 2606 OID 17931)
-- Name: rajad rajad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rajad
    ADD CONSTRAINT rajad_pkey PRIMARY KEY (id);


--
-- TOC entry 4768 (class 2606 OID 17933)
-- Name: treenerid treenerid_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treenerid
    ADD CONSTRAINT treenerid_email_key UNIQUE (email);


--
-- TOC entry 4770 (class 2606 OID 17935)
-- Name: treenerid treenerid_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treenerid
    ADD CONSTRAINT treenerid_pkey PRIMARY KEY (id);


--
-- TOC entry 4772 (class 2606 OID 17937)
-- Name: tulemuse_auhinnad tulemuse_auhinnad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tulemuse_auhinnad
    ADD CONSTRAINT tulemuse_auhinnad_pkey PRIMARY KEY (id);


--
-- TOC entry 4774 (class 2606 OID 17939)
-- Name: tulemused tulemused_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tulemused
    ADD CONSTRAINT tulemused_pkey PRIMARY KEY (id);


--
-- TOC entry 4775 (class 2606 OID 17940)
-- Name: jooksjad jooksjad_fk5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jooksjad
    ADD CONSTRAINT jooksjad_fk5 FOREIGN KEY (klubi) REFERENCES public.klubid(id);


--
-- TOC entry 4776 (class 2606 OID 17945)
-- Name: maraton maraton_fk3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maraton
    ADD CONSTRAINT maraton_fk3 FOREIGN KEY (raja_id) REFERENCES public.rajad(id);


--
-- TOC entry 4777 (class 2606 OID 17950)
-- Name: maraton maraton_fk4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maraton
    ADD CONSTRAINT maraton_fk4 FOREIGN KEY (maratonide_sari_id) REFERENCES public.maratonide_sari(id);


--
-- TOC entry 4778 (class 2606 OID 17955)
-- Name: maratonide_sari maratonide_sari_fk2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maratonide_sari
    ADD CONSTRAINT maratonide_sari_fk2 FOREIGN KEY (peasponsor_id) REFERENCES public.peasponsorid(id);


--
-- TOC entry 4779 (class 2606 OID 17960)
-- Name: treenerid treenerid_fk1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treenerid
    ADD CONSTRAINT treenerid_fk1 FOREIGN KEY (klubi) REFERENCES public.klubid(id);


--
-- TOC entry 4780 (class 2606 OID 17965)
-- Name: tulemuse_auhinnad tulemuse_auhinnad_fk1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tulemuse_auhinnad
    ADD CONSTRAINT tulemuse_auhinnad_fk1 FOREIGN KEY (tulemus_id) REFERENCES public.tulemused(id);


--
-- TOC entry 4781 (class 2606 OID 17970)
-- Name: tulemuse_auhinnad tulemuse_auhinnad_fk2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tulemuse_auhinnad
    ADD CONSTRAINT tulemuse_auhinnad_fk2 FOREIGN KEY (auhind_id) REFERENCES public.auhinnad(id);


--
-- TOC entry 4782 (class 2606 OID 17975)
-- Name: tulemused tulemused_fk1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tulemused
    ADD CONSTRAINT tulemused_fk1 FOREIGN KEY (jaaksja_id) REFERENCES public.jooksjad(id);


--
-- TOC entry 4783 (class 2606 OID 17980)
-- Name: tulemused tulemused_fk2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tulemused
    ADD CONSTRAINT tulemused_fk2 FOREIGN KEY (maraton_id) REFERENCES public.maraton(id);


-- Completed on 2024-05-05 22:46:29

--
-- PostgreSQL database dump complete
--

