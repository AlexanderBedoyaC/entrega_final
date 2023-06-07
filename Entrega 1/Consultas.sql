/* Crear tabla “accident”: */
CREATE TABLE IF NOT EXISTS Entrega1.accident (

                        accident_id INT64 NOT NULL,
                           ST_CASE INT64, VE_TOTAL INT64,
                           VE_FORMS INT64,PEDS INT64,PERSONS INT64,
                           COUNTY INT64,county_name STRING,CITY INT64,
                           city_name STRING,DAY INT64,MONTH INT64,
                           YEAR INT64,HOUR INT64,MINUTE INT64,
                           NHS INT64,FUNC_SYS STRING,func_sys_lit STRING,
                           ROAD_FNC STRING,road_fnc_lit STRING,
                           RD_OWNER STRING,rd_owner_lit STRING,
                           TWAY_ID STRING,TWAY_ID2 STRING,
                           LATITUDE NUMERIC(11,9),LONGITUD NUMERIC(13,9),
                           SP_JUR INT64,sp_jur_lit STRING,
                           HARM_EV INT64,harm_ev_lit STRING,
                           MAN_COLL INT64,man_coll_lit STRING,
                           RELJCT1 INT64,RELJCT2 INT64,TYP_INT INT64,
                           WRK_ZONE INT64,REL_ROAD INT64,LGT_COND INT64,
                           lgt_cond_lit STRING,WEATHER INT64,
                           weather_lit STRING,SCH_BUS STRING,CF1 INT64,
                           CF2 INT64,CF3 INT64,cf1_lit STRING,
                           cf2_lit STRING,cf3_lit STRING,
                           FATALS INT64,A_INTER INT64,
                           a_inter_lit STRING,A_ROADFC INT64,
                           a_road_fc_lit STRING,A_TOD INT64,
                           a_tod_lit STRING,A_DOW INT64,
                           a_dow_lit STRING,A_LT INT64,a_lt_lit STRING,
                           A_SPCRA INT64,a_spcra_lit STRING,
                           A_PED INT64,a_ped_lit STRING,A_PED_F INT64,
                           a_ped_f_lit STRING,
                           A_PEDAL INT64,a_pedal_lit STRING,
                           A_PEDAL_F INT64,a_pedal_f_lit STRING,
                           A_POLPUR INT64,a_polour_lit STRING,
                           A_POSBAC INT64,a_posbac_lit STRING,
                           A_DIST INT64,a_dist_lit STRING,
                           A_DROWSY INT64,a_drowsy_lit STRING,
                           INDIAN_RES INT64,indian_res_lit STRING);
/* Crear tabla “person”: */
CREATE TABLE IF NOT EXISTS person (accident_id INT64,
                            STATE INT64,ST_CASE INT64,
                            VE_FORMS INT64,VEH_NO INT64,PER_NO INT64,
                            STR_VEH INT64,COUNTY INT64,DAY INT64,
                            MONTH INT64,HOUR INT64,MINUTE INT64,
                            RUR_URB STRING,FUNC_SYS STRING,
                            HARM_EV INT64,MAN_COLL INT64,
                            SCH_BUS INT64,MAKE STRING,MAK_MOD STRING,
                            BODY_TYP STRING,MOD_YEAR STRING,
                            TOW_VEH STRING,SPEC_USE STRING,
                            EMER_USE STRING,ROLLOVER STRING,
                            IMPACT1 STRING,FIRE_EXP STRING,
                            AGE INT64,SEX INT64,PER_TYP INT64,
                            INJ_SEV INT64,SEAT_POS INT64,
                            REST_USE INT64,REST_MIS INT64,
                            AIR_BAG INT64,EJECTION INT64,
                            EJ_PATH INT64,EXTRICAT INT64,
                            DRINKING INT64,ALC_DET INT64,
                            ALC_STATUS INT64,ATST_TYP INT64,
                            ALC_RES INT64,DRUGS INT64,
                            DRUG_DET INT64,DSTATUS INT64,
                            DRUGTST1 INT64,DRUGTST2 INT64,
                            DRUGTST3 INT64,DRUGRES1 INT64,
                            DRUGRES2 INT64,DRUGRES3 INT64,
                            HOSPITAL INT64,DOA INT64,DEATH_DA INT64,
                            DEATH_MO INT64,DEATH_YR INT64,
                            DEATH_HR INT64,DEATH_MN INT64,
                            DEATH_TM INT64,LAG_HRS INT64,
                            LAG_MINS INT64,P_SF1 INT64,P_SF2 INT64,
                            P_SF3 INT64,WORK_INJ INT64,HISPANIC INT64,
                            RACE INT64,LOCATION INT64,ROAD_FNC STRING,
                            CERT_NO STRING,VINTYPE STRING,
                            VINMAKE STRING,VINA_MOD STRING,
                            VIN_BT STRING,VINMODYR STRING,
                            VIN_LNGT STRING,VIN_WGT STRING,
                            WGTCD_TR STRING,WHLBS_LG STRING,
                            WHLBS_SH STRING,SER_TR STRING,
                            FUELCODE STRING,MCYCL_DS STRING,
                            CARBUR STRING,CYLINDER STRING,
                            DISPLACE STRING,MCYCL_CY STRING,
                            TIRE_SZE STRING,TON_RAT STRING,
                            TRK_WT STRING,TRKWTVAR STRING,
                            MCYCL_WT STRING,VIN_REST STRING,
                            WHLDRWHL STRING,Year INT64,
                                FOREIGN KEY (accident_id)
                               REFERENCES Entrega1.accident(accident_id) );




/* 1. Muestre la cantidad de muertos por condado. */

SELECT county_name as Condado, sum(FATALS) as Muertes 
FROM `arizonafatalaccidents.Entrega1.accident`
WHERE county_name != '999'
GROUP BY county_name
ORDER BY Muertes DESC;

/* 2. ¿En qué condición climática se presentaron más accidentes? */

SELECT weather_lit, COUNT(ST_CASE) as cant_acc 
FROM `arizonafatalaccidents.Entrega1.accident`
WHERE weather_lit NOT IN ('Unknown','Not Reported','Other')
GROUP BY weather_lit
ORDER BY cant_acc DESC;

/* 3. ¿Cuáles han sido los eventos por los que se han registrado más personas fallecidas? */

SELECT harm_ev_lit, sum(FATALS) as cant_fat 
FROM `arizonafatalaccidents.Entrega1.accident`
WHERE harm_ev_lit != 'Unknown'
GROUP BY harm_ev_lit
ORDER BY cant_fat DESC;

/* 4. Determine la edad promedio de las personas según la severidad de las lesiones y qué lesiones se presentan más en los accidentes por condado. */

SELECT county_name,case 
                    when INJ_SEV= 0 then "No_Apparent_Injury"
                    when INJ_SEV= 1 then "Possible_Injury"
                    when INJ_SEV= 2 then "Suspected_Minor_Injury"
                    when INJ_SEV= 3 then "Suspected_Serious_Injury"
                    when INJ_SEV= 4 then "Fatal_Injury"
                    when INJ_SEV= 5 then "Injure_Severity_Unknown"
                    when INJ_SEV= 6 then "Died_Prior_to_Crash"
                    when INJ_SEV= 9 then "Unknowk_Not_Reported"
                    end as INJ_SEV, COUNT(1) AS cantidad,
    round(avg(case when AGE = 998 or AGE = 999 then 0
              else AGE end)) as edad_promedio
FROM `arizonafatalaccidents.Entrega1.accident` acc
JOIN `arizonafatalaccidents.Entrega1.person` per
ON acc.accident_id = per.accident_id
GROUP BY county_name,INJ_SEV
order by cantidad desc;


/* 5. ¿Cuáles fueron los años en los que más se presentaron accidentes? */

SELECT YEAR ,COUNT(ST_CASE) as cant_acc 
FROM `arizonafatalaccidents.Entrega1.accident` 
GROUP BY YEAR
ORDER BY cant_acc DESC;

/* 6. ¿Cuál es el momento del día (día, noche) con el mayor número de muertes en accidentes de tránsito por año? */

SELECT YEAR AS Anio, a_tod_lit AS ParteDia, SUM(FATAlS) AS Muertes
FROM `arizonafatalaccidents.Entrega1.accident`
GROUP BY YEAR, a_tod_lit
ORDER BY YEAR, Muertes DESC;

/* 7. ¿Cuántas muertes en accidentes de tránsito al año involucran conductores distraídos o somnolientos o ambos? ¿Qué porcentaje de estas personas involucradas estaban bajo los efectos de drogas o alcohol o ambos por encima del límite legal? */

select ac.YEAR AS Anio,
    case
      when ac.a_dist_lit = 'Involving a Distracted Driver' and ac.a_drowsy_lit = 'Other Crash' then 'Distraido'
      when ac.a_dist_lit = 'Other Crash' and ac.a_drowsy_lit = 'Involving a Drowsy Driver' then 'Somnoliento'
      when ac.a_dist_lit = 'Involving a Distracted Driver' and ac.a_drowsy_lit = 'Involving a Drowsy Driver' then 'Distraido y Somnoliento'
      else 'Ninguno'
    end as Distraido_o_Somnoliento,

    sum(case when pr.INJ_SEV = 4 then 1 else 0 end) as Muertes, /* Injury severity = 4 es heridas que fatales en la persona involucrada */

    concat(cast(round((sum(case
                            when pr.ALC_STATUS = 2 and pr.DSTATUS != 2 then 1
                            else 0
                          end)/count(1))*100, 4) as string), '%') as SoloAlcoholizadas,

    concat(cast(round((sum(case
                            when pr.ALC_STATUS != 2 and pr.DSTATUS = 2 then 1
                            else 0
                          end)/count(1))*100, 4) as string), '%') as SoloDrogadas,

    concat(cast(round((sum(case
                            when pr.ALC_STATUS = 2 and pr.DSTATUS = 2 then 1
                            else 0
                          end)/count(1))*100, 4) as string), '%') as Alcoholizadas_y_Drogadas        
from `arizonafatalaccidents.Entrega1.accident` as ac
join `arizonafatalaccidents.Entrega1.person` as pr
on ac.accident_id = pr.accident_id
group by ac.YEAR, Distraido_o_Somnoliento
order by ac.YEAR, Distraido_o_Somnoliento;

/* 8. ¿Por días de la semana y por cada año, cuántas personas de cada sexo murieron en accidentes de tránsito y cuál es el promedio de edad de estas personas? */

select ac.YEAR as Anio,
        case
          when EXTRACT(dayofweek FROM DATE (CONCAT(ac.YEAR,'-',ac.MONTH,'-',ac.DAY))) = 1 then 'Domingo'
          when EXTRACT(dayofweek FROM DATE (CONCAT(ac.YEAR,'-',ac.MONTH,'-',ac.DAY))) = 2 then 'Lunes'
          when EXTRACT(dayofweek FROM DATE (CONCAT(ac.YEAR,'-',ac.MONTH,'-',ac.DAY))) = 3 then 'Martes'
          when EXTRACT(dayofweek FROM DATE (CONCAT(ac.YEAR,'-',ac.MONTH,'-',ac.DAY))) = 4 then 'Miercoles'
          when EXTRACT(dayofweek FROM DATE (CONCAT(ac.YEAR,'-',ac.MONTH,'-',ac.DAY))) = 5 then 'Jueves'
          when EXTRACT(dayofweek FROM DATE (CONCAT(ac.YEAR,'-',ac.MONTH,'-',ac.DAY))) = 6 then 'Viernes'
          when EXTRACT(dayofweek FROM DATE (CONCAT(ac.YEAR,'-',ac.MONTH,'-',ac.DAY))) = 7 then 'Sabado'
        end as Dia,
        case
          when pr.sex = 1 then 'Masculino'
          when pr.sex = 2 then 'Femenino'
          when pr.sex = 8 then 'No reportado'
          else 'Desconocido'
        end as Sexo,
        sum(case when pr.INJ_SEV = 4 then 1 end) as Muertes,    /* Injury severity = 4 es heridas que fatales en la persona involucrada */
        round(avg(case
          when pr.AGE = 998 or pr.AGE = 999 then 0             /* AGE = 998 es no reportado y AGE = 999 es Desconocida */
          else pr.AGE
        end), 0) as EdadPromedio
from `arizonafatalaccidents.Entrega1.accident` as ac
join `arizonafatalaccidents.Entrega1.person` as pr
on ac.accident_id = pr.accident_id
group by Anio, Dia, Sexo
having Sexo in ('Masculino', 'Femenino')
order by Anio, Muertes desc;

/* 9. ¿Por año, cuántos accidentes de tránsito involucran vehículos con más de 10 años de antigüedad? */

select ac.YEAR as Anio,
        count(distinct ac.accident_id) as AccidentesFatales,
        count(vh.accident_id) as VehiculosViejos
from `arizonafatalaccidents.Entrega1.accident` as ac
join `arizonafatalaccidents.Entrega1.vehicle` as vh
on ac.accident_id = vh.accident_id
where (ac.YEAR - vh.MOD_YEAR) > 10
group by Anio
order by Anio;

/* 10. ¿Cuál es la marca de vehículo que registra más accidentes de tránsito fatales por año? */

select vhmk.Attributes as Marca,
        count(ac.accident_id) as TotalAccidentes,
        ifnull(sum(case when ac.YEAR=2012 then 1 end), 0) as _2012,
        ifnull(sum(case when ac.YEAR=2013 then 1 end), 0) as _2013,
        ifnull(sum(case when ac.YEAR=2014 then 1 end), 0) as _2014,
        ifnull(sum(case when ac.YEAR=2015 then 1 end), 0) as _2015,
        ifnull(sum(case when ac.YEAR=2016 then 1 end), 0) as _2016
from `Entrega1.vehiclemake` as vhmk
right join `Entrega1.vehicle` as vh
on vhmk.Codes = vh.MAKE
left join `arizonafatalaccidents.Entrega1.accident` as ac
on vh.accident_id = ac.accident_id
group by Marca
order by TotalAccidentes desc;

/* 11. ¿En cuántos accidentes de tránsito se ven envueltos peatones y ciclistas al año? */

select YEAR,
        count(1) as AccidentesTotales,
        sum(case when a_ped_lit='Pedestrian Involved Crash' then 1 end) as PeatonesInvolucrados, 
        sum(case when a_pedal_lit='Pedalcyclist Involved Crash' then 1 end) as CiclistasInvolucrados
from `arizonafatalaccidents.Entrega1.accident`
group by YEAR;

/* 12. ¿Agrupando por ciudad, cuántos vehículos se fugaron en los accidentes?  */

With fugas as (
            select vh.accident_id,
        sum(case when vh.Hit_run=9 then 1 else 0 end) as Desconocida_fuga,
        sum(case when vh.Hit_run=0 then 1 else 0 end) as No_fuga,
        sum(case when vh.Hit_run=1 then 1 else 0 end) as Si_fuga
from `arizonafatalaccidents.Entrega1.vehicle` as vh
group by vh.accident_id    
order by No_fuga desc,Si_fuga desc 
)
select city_name,sum(No_fuga) as No_fuga,sum(Si_fuga) as Si_fuga,sum(Desconocida_fuga) as Desconocida_fuga
from `arizonafatalaccidents.Entrega1.accident` acc
join fugas on fugas.accident_id = acc.accident_id
group by city_name
order by si_fuga desc;

/* 13. ¿La activación del Airbag disminuye la cantidad de muertes en promedio?¿Que tipo de activación es  mejor?  */

with conteo as (
select count(1) as conteo 
from `arizonafatalaccidents.Entrega1.person` )
SELECT case
          when AIR_BAG= 00 then "Not Applicable"
          when AIR_BAG= 01 then "Deployed-Front"
          when AIR_BAG= 02 then "Deployed-Side (door, seatback)" 
          when AIR_BAG= 03 then "Deployed-Curtain (roof)"
          when AIR_BAG= 07 then "Deployed-Other (knee, air belt, etc.)"
          when AIR_BAG= 08 then "Deployed-Combination" 
          when AIR_BAG= 09 then "Deployment-Unknown Location"
          when AIR_BAG= 20 then "Not Deployed"
          when AIR_BAG= 28 then "Switched Off"
          when AIR_BAG= 98 then "Not Reported"
          when AIR_BAG= 99 or AIR_BAG= 97  then "Deployment Unknown"
          end as AIR_BAG,
conteo.conteo as conteo,
concat(ifnull(round((SUM(case when INJ_SEV= 0 then 1 end)/10611)*100,4),0),'%')  as No_Apparent_Injury,
concat(ifnull(round((SUM(case when INJ_SEV= 1 then 1 end)/10611)*100,4),0),'%') as Possible_Injury,
concat(ifnull(round((SUM(case when INJ_SEV= 2 then 1 end)/10611)*100,4),0), '%' ) as Suspected_Minor_Injury,
concat(ifnull(round((SUM(case when INJ_SEV= 3 then 1 end)/10611)*100,4),0), '%') as Suspected_Serious_Injury,
concat(ifnull(round((SUM(case when INJ_SEV= 4 then 1 end)/10611)*100,4),0), '%') as Fatal_Injury,
concat(ifnull(round((SUM(case when INJ_SEV= 5 then 1 end)/10611)*100,4),0), '%') as Injure_Severity_Unknown,
concat(ifnull(round((SUM(case when INJ_SEV= 6 then 1 end)/10611)*100,4),0), '%') as Died_Prior_to_Crash,
concat(ifnull(round((SUM(case when INJ_SEV= 9 then 1 end)/10611)*100,4),0), '%') as Unknowk_Not_Reported
from `arizonafatalaccidents.Entrega1.person`,conteo
where AIR_BAG not in (00,98,99,97)
group by AIR_BAG,conteo;

/* 14. ¿Cuántos accidentes por mes están relacionados con personas en estado de embriaguez? ¿Está relacionado con el mes con más accidentes?  */

with t1 as (select month, count(1) as Accidentes
            from `arizonafatalaccidents.Entrega1.accident`
            group by MONTH
            order by MONTH
            limit 1)
select format_date("%B",DATE(concat(YEAR,"-",acc.MONTH,"-",DAY))) as Mes,
        sum(case when a_posbac= 1 then 1 end) as Embriagados, 
        format_date("%B",DATE(concat(YEAR,"-",t1.month,"-",DAY))) as mes_acc, 
        t1.Accidentes 
from `arizonafatalaccidents.Entrega1.accident` as acc, t1
group by mes, mes_acc, t1.Accidentes
order by embriagados desc;

/* 15.  ¿Cuántos accidentes hay por la condición de la luz?  */

SELECT lgt_cond_lit, count(1) as Accidentes 
FROM `arizonafatalaccidents.Entrega1.accident` 
where lgt_cond_lit != "Unknown" and lgt_cond_lit != "Not Reported"
GROUP BY lgt_cond_lit;

/* 16. Muestre la cantidad de accidentes por año donde se involucren hispanos */

SELECT YEAR, count(1) as Total_accidentes,sum(case
  WHEN HISPANIC BETWEEN 01 AND 06 THEN 1
  ELSE 0
  END) AS HISPANIC from `arizonafatalaccidents.Entrega1.person`
GROUP BY YEAR;
/* 
17.¿Cuál fue el accidente con más víctimas fatales por año? ¿Está relacionado con velocidad, alcohol o drogas? */

with id as(
          with id2012  as (
                        select accident_id,year,VE_TOTAL,FATALS,a_spcra_lit, a_posbac_lit 
                        from `arizonafatalaccidents.Entrega1.accident`
                        where year= 2012
                        order by FATALS desc
                        limit 1),
              id2013 as (select accident_id,year,VE_TOTAL,FATALS,a_spcra_lit, a_posbac_lit 
                        from `arizonafatalaccidents.Entrega1.accident`
                        where year= 2013
                        order by FATALS desc
                        limit 1),
              id2014 as (select accident_id,year,VE_TOTAL, FATALS, a_spcra_lit,  a_posbac_lit  
                        from `arizonafatalaccidents.Entrega1.accident`
                        where year= 2014
                        order by FATALS desc
                        limit 1),
              id2015 as (select accident_id,year,VE_TOTAL,FATALS,a_spcra_lit, a_posbac_lit  
                        from `arizonafatalaccidents.Entrega1.accident`
                        where year= 2015
                        order by FATALS desc
                        limit 1),
              id2016 as (select accident_id,year,VE_TOTAL,FATALS,a_spcra_lit, a_posbac_lit  
                        from `arizonafatalaccidents.Entrega1.accident`
                        where year= 2016
                        order by FATALS desc
                        limit 1)
      select * from id2012 union all
      select * from id2013 union all
      select * from id2014 union all
      select * from id2015 union all
      select * from id2016 
)
select id.accident_id,id.year,VE_TOTAL as Vehiculos_involucrados, 
        FATALS as Muertes,a_spcra_lit as Velocidad_involucrada,
        a_posbac_lit as Alcohol_involucrado
from id 
order by year;

/* 18.¿Agrupando por la velocidad cual es el promedio de muertes? */

select case 
        when TRAV_SP=0 then "Detenido"
        when TRAV_SP between 1 and 30 then "00-30"
        when TRAV_SP between 31 and 60 then "030-60"
        when TRAV_SP between 61 and 90 then "060-90"
        when TRAV_SP between 91 and 120 then "090-120"
        when TRAV_SP between 121 and 150 then "120-150"
        when TRAV_SP between 150 and 997 then "150+"
        else "Unknown"
        end as TRAV_SP,
      round(avg(deaths),2) as muertes,round(avg(NUMOCCS),2) as Ocupantes,count(1) as Vehiculos,
      concat((round(avg(if(NUMOCCS!=0,deaths/NUMOCCS,0)),2))*100,"%") as MuertesxOcupantes
from `arizonafatalaccidents.Entrega1.vehicle`
group by TRAV_SP
order by TRAV_SP;

/* 19.¿Cuál es la carretera donde se presentan más muertes por accidente de tránsito por año y qué tipo de vehículo es el que suele accidentarse más en esta? ¿Es rural o urbana? */

select t2.accident_id,
        t2.YEAR as Anio,
        t2.TWAY_ID as Carretera,
        if(strpos(t2.road_fnc_lit, '-')>0, substring(t2.road_fnc_lit, 1, strpos(t2.road_fnc_lit, '-')-1), "Desconocido") as Rural_o_Urbano,
        t2.FATALS as Muertes, 
        bt.Attributes as TipoVehiculo
from (with t1 as (select ac.accident_id, max(ac.FATALS) as Muertes
                  from `arizonafatalaccidents.Entrega1.accident` ac
                  group by ac.accident_id
                  order by Muertes desc
                  limit 5)
          select ac.YEAR, ac.accident_id, ac.TWAY_ID, ac.road_fnc_lit, ac.FATALS
          from `arizonafatalaccidents.Entrega1.accident` as ac
          inner join t1
          on ac.accident_id = t1.accident_id) as t2
join `Entrega1.vehicle` as vh
on t2.accident_id = vh.accident_id
join `Entrega1.bodytypes` as bt
on vh.BODY_TYP = bt.Codes
order by Muertes DESC, t2.accident_id;

/* 20. En los accidentes de tránsito ¿En cuántos va manejando el dueño?   */

WITH CONTEO AS (SELECT COUNT(1) AS TOTAL FROM `arizonafatalaccidents.Entrega1.vehicle` )
SELECT CONTEO.TOTAL AS CONTEO,
          CASE 
            WHEN OWNER= 0 THEN "VEHÍCULO NO REGISTRADO"
            WHEN OWNER= 1 THEN "VEHÍCULO PROPIO"
            WHEN OWNER= 2 THEN "VEHÍCULO NO PROPIO"
            WHEN OWNER= 3 THEN "VEHÍCULO EMPRESARIAL"
            WHEN OWNER= 4 THEN "VEHÍCULO RENTADO"
            WHEN OWNER= 5 THEN "VEHÍCULO ROBADO"
            WHEN OWNER= 6 THEN "SIN CONDUCTOR"
            WHEN OWNER= 9 THEN "DESCONOCIDO"
          END AS OWNER, COUNT(1) AS VEHICULOS, COUNT(1)/CONTEO.TOTAL AS PORC
FROM `arizonafatalaccidents.Entrega1.vehicle`, CONTEO 
group by OWNER, CONTEO