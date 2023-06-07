#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri May 12 17:28:25 2023

@author: Alexander Bedoya, Brahayan Gil y Sebastián Salamanca
"""

# Cargar datos
import streamlit as st
import pandas as pd
import numpy as np
import pydeck as pdk #Mapas avanzados
import plotly.express as px
import plotly.graph_objects as go
import plotly.subplots
from plotly.subplots import make_subplots
import base64

# Función para descargar base de datos
def get_table_download_link(df):
    csv = df.to_csv(index=False)
    b64 = base64.b64encode(csv.encode()).decode()  # some strings <-> bytes conversions necessary here
    href = f'<a href="data:file/csv;base64,{b64}" download="datos.csv">Descargar archivo csv</a>'
    return href

# Utilizar la página completa en lugar de una columna central estrecha
st.set_page_config(layout="wide")


# Título principal, h1 denota el estilo del título 1
st.markdown("<h1 style='text-align: center; color: #951F0F;'>Accidentes fatales en Arizona entre 2012 y 2016</h1>", unsafe_allow_html=True)

# Cargar datos
#st.cache_resource.clear()
#@st.cache_resource # Código para que quede almacenada la información en el cache
def load_data():
    acc = pd.read_csv('acc.csv')
    vh_fn = pd.read_csv('vh_fn.csv')
    pr_fn = pd.read_csv('pr_fn.csv')
    vh_mk = pd.read_csv('vh_mk.csv', sep=';')
    return acc, vh_fn,pr_fn, vh_mk

acc,vh_fn, pr_fn, vh_mk = load_data()

# Indicadores clave
c1, c2, c3 = st.columns((2,1,4))
anio = c1.slider("", 2012, 2016, label_visibility="collapsed")
if c2.button('Ver todos los años', use_container_width=True):
  total_acc = acc.shape[0]
  total_vh = vh_fn.shape[0]
  total_pr = pr_fn.shape[0]
  total_fatals = acc['fatals'].sum()
  mort = total_fatals/total_pr
else:
  total_acc = acc[acc['year'] == anio].shape[0]
  total_vh = vh_fn[vh_fn['year'] == anio].shape[0]
  total_pr = pr_fn[pr_fn['year'] == anio].shape[0]
  total_fatals = acc[acc['year'] == anio]['fatals'].sum()
  mort = total_fatals/total_pr

top_hora = acc.groupby(['hour'])[['accident_id']].count().reset_index().rename(columns={'accident_id':'accidents'}).nlargest(n=1, columns='accidents')
top_condado = acc.groupby(['county_name'])[['accident_id']].count().reset_index().rename(
    columns={'accident_id': 'accidents'}).nlargest(n=1, columns='accidents')
top_sexo = pr_fn.groupby(['sex'])[['accident_id']].count().rename(columns={'accident_id': 'accidents'})

c1, c2, c3, c4, c5, c6, c7 = st.columns((1, 1, 1, 0.5, 1, 1, 1.5))
c1.write('<h3 style="margin: 0; padding: 0; text-align: center; color:#888;" >Total de accidentes</h3><h2 style="text-align: center;" >'+str(total_acc)+'</h2>', unsafe_allow_html=True)
c2.write('<h3 style="margin: 0; padding: 0; text-align: center; color:#888;" >Total de vehículos</h3><h2 style="text-align: center;" >'+str(total_vh)+'</h2>', unsafe_allow_html=True)
c3.write('<h3 style="margin: 0; padding: 0; text-align: center; color:#888;" >Tasa de mortalidad</h3><h2 style="text-align: center;" >'+str(round(mort, 2)*100)+'%</h2>', unsafe_allow_html=True)
c5.write('<h3 style="margin: 0; padding: 0; text-align: center; color:#888;" >TOP 1 - Hora del día</h3><h4 style="text-align: center;" >' + str(int(top_hora.hour.values[0])) + ':00 - '+
         str(top_hora.accidents.values[0])+' accidentes</h4>', unsafe_allow_html=True)
c6.write('<h3 style="margin: 0; padding: 0; text-align: center; color:#888;" >TOP 1 - Condado</h3><h4 style="text-align: center;" >' + str(top_condado.county_name.values[0])+'</h4>', unsafe_allow_html=True)
c7.write('<h3 style="margin: 0; padding: 0; text-align: center; color:#888;" >Accidentados por sexo</h3><h4 style="text-align: center;" >Femenino: ' +
         str(top_sexo.iloc[0, 0])+' - Masculino:'+str(top_sexo.iloc[0, 0])+'</h4>', unsafe_allow_html=True)

#----------------------------------------
c1, c2 = st.columns((1.5, 1)) # Dividir el ancho en 5 columnas de igual tamaño

base1 = acc.groupby(['county_name']).agg({'accident_id':'count', 'fatals':'sum'}).reset_index().rename(columns={'accident_id':'accidents'}).sort_values('accidents', ascending=False)
fig = px.bar(base1, x='county_name', y=['accidents', 'fatals'], title='Comparación de Accidentes y Muertes por Condado', barmode='group', text_auto=True)
fig.update_layout(
    title=dict(text='Accidents and fatals by county', x=0.4)
    )
fig.update_traces(textfont_size=12, textangle=90, textposition="outside", cliponaxis=False)
c1.plotly_chart(fig,use_container_width=True)

token_map = "pk.eyJ1IjoiYWxleGJlZCIsImEiOiJjbGgxNHgxdHUwZWJrM21tdzYxNmIzenZnIn0.dDeB0SSguteCnzctb8LCxw"
px.set_mapbox_access_token(token_map)
fig = px.scatter_mapbox(acc, lat='latitude', lon='longitud', color='county_name', mapbox_style='streets',
                        color_continuous_scale=px.colors.cyclical.IceFire, size_max=30, zoom=5)
fig.update_layout(
    title=dict(text='Accidents by county', x=0.3),
    width=520)
c2.plotly_chart(fig,use_container_width=True)

#----------------------------------

base2 = acc.groupby(['year', 'month']).agg({'accident_id':'count', 'fatals':'sum'}).reset_index().rename(columns={'accident_id':'accidents'})
year_month = base2.apply(lambda x: str(x['year']) + '-' + str(x['month']), axis =1)
base2 = base2.set_index(year_month).drop(['year', 'month'], axis=1)
fig = px.line(base2)
fig.update_layout(
    xaxis=dict(title='Month - Year'),
    title=dict(text='Accidents and fatals by month-year', x=0.3),
)
st.plotly_chart(fig,use_container_width=True)

#-------------------------------------------
c1, c2 = st.columns((1, 1))

acc['day_part'] = acc['hour'].apply(lambda x: 'Morning' if x<=11 and x>=4 else 'Afternoon' if x>=12 and x<=19 else 'Night')
base3 = acc.groupby(['day_part']).agg({'accident_id':'count', 'fatals':'sum'}).reset_index().rename(columns={'accident_id':'accidents'})

fig = make_subplots(rows=1, cols=2, specs=[[{'type':'domain'}, {'type':'domain'}]])
fig.add_trace(go.Pie(labels=base3['day_part'], values=base3['accidents'], name="accidents"),1, 1)

fig.add_trace(go.Pie(labels=base3['day_part'], values=base3['fatals'], name="fatals"), 1, 2)

fig.update_traces(hole=.4, hoverinfo="label+percent+name", textinfo='value')

fig.update_layout(
    annotations=[dict(text='Accidents', x=0.158, y=0.5, font_size=12, showarrow=False),
                 dict(text='Fatals', x=0.831, y=0.5, font_size=12, showarrow=False)],
    title=dict(text='Accidents and fatals by day-part', x=0.27),
   
                  )
c1.plotly_chart(fig,use_container_width=True)

base4 = acc.groupby(['weather_lit']).agg({'accident_id':'count', 'fatals':'sum'}).reset_index().rename(columns={'accident_id':'accidents'})

fig = px.bar(base4.sort_values('accidents', ascending=False), x='weather_lit', y=['accidents', 'fatals'], barmode='group', text_auto=True)
fig.update_layout(
    title=dict(text='Accidents and fatals by weather', x=0.3),

                  )

c2.plotly_chart(fig,use_container_width=True)


#---------------------------
c1, c2 = st.columns((1.5, 1))

base5 = vh_fn.groupby(['mod_year']).agg({'accident_id':'count', 'fatals':'sum'}).reset_index().rename(columns={'accident_id':'accidents'})
base5 = base5.set_index('mod_year')

fig = px.line(base5)
fig.update_layout(
    xaxis=dict(title='Model year'),
    yaxis=dict(title='Value'),
    title=dict(text='Accidents and fatals by model year', x=0.3),
)

c1.plotly_chart(fig,use_container_width=True)

drugs = pr_fn[pr_fn['drugs']=='Yes'].groupby(['accident_id']).count().shape[0]
alc = pr_fn[pr_fn['alc_res']>0].groupby(['accident_id']).count().shape[0]
base6 = pd.DataFrame({'category':['drugs', 'alcohol'], 'accidents':[drugs, alc]})
fig = px.pie(base6, values='accidents', names='category')
fig.update_layout( title=dict(text='Fatal accidents involving drugged or alcoholic people'))
c2.plotly_chart(fig,use_container_width=True)

#---------------------------
c1, c2 = st.columns((1, 1))

base7 = pr_fn[pr_fn['dead']==1].groupby(['year','sex']).agg({'dead':'sum', 'age':'mean'})
base7 = base7.reset_index().rename(columns={'dead':'fatals'})

fig = px.line(base7, x='year', y='fatals', color='sex', markers=True)
rango_y = [0, 700]
fig.update_layout(
    title=dict(text='Deads by sex and year', x=0.3),
    yaxis=dict(range=rango_y),
   
)
c1.plotly_chart(fig,use_container_width=True)
fig = px.line(base7, x='year', y='age', color='sex', markers=True)
fig.update_layout(
    title=dict(text='Mean age of deads by year', x=0.3),
   
)
c2.plotly_chart(fig,use_container_width=True)
#---------------------------
vh_mk = vh_mk.rename(columns={'Codes': 'make'})
vh_mk['make'] = vh_mk['make'].astype(str)
base8 = vh_fn.merge(vh_mk, how='left', on='make')
base8 = base8.rename(columns={'Attributes':'marca_name'}).fillna('Unknown')

# crear base
df0 = base8.groupby(['marca_name'])[['accident_id']].count().sort_values('accident_id', ascending = False).rename(columns={'accident_id':'accidents'})
df0['ratio'] = df0.apply(lambda x: x.cumsum()/df0['accidents'].sum())
# definir figura
fig = go.Figure([go.Bar(x=df0.index, y=df0['accidents'], yaxis='y1', name='accidentes de transito'),
                 go.Scatter(x=df0.index, y=df0['ratio'], yaxis='y2', name='accidentes de transito', hovertemplate='%{y:.1%}', marker={'color': '#000000'})])

# agregar detalles
fig.update_layout(template='plotly_white', showlegend=False, hovermode='x', bargap=.3,
                  title={'text': '<b>Total de vehiculos involucrados en accidentes según la marca<b>', 'x': .5}, 
                  yaxis={'title': 'accidentes'},
                  yaxis2={'rangemode': "tozero", 'overlaying': 'y', 'position': 1, 'side': 'right', 'title': 'ratio', 'tickvals': np.arange(0, 1.1, .2), 'tickmode': 'array', 'ticktext': [str(i) + '%' for i in range(0, 101, 20)]})

st.plotly_chart(fig,use_container_width=True)
#---------------------------
c1, c3, c2 = st.columns((2,0.3,1))
base9 = pr_fn.groupby(['air_bag']).agg({'dead':'sum'}).reset_index().rename(columns={ 'dead':'fatals'})
fig = px.pie(base9, values='fatals', names='air_bag')
fig.update_layout(title=dict(text='Fatals by type of airbag activation', x=0.5))
c1.plotly_chart(fig,use_container_width=True)
c2.write(base9)


#checbox para descargar datos
# Hacer un checkbox
c1, c2, c3 = st.columns((1,1,1))

#Descargar datos de accidentes
if c1.checkbox('Obtener datos de accidentes por año y condado', False):
    
    # Código para generar el DataFrame
    df2 = acc.groupby(['year','county_name'])[['accident_id']].count().reset_index().rename(columns ={'accident_id':'accidents'})
    
    # Código para convertir el DataFrame en una tabla plotly resumen
    fig = go.Figure(data=[go.Table(
        header=dict(values=list(df2.columns),
        fill_color='lightblue',
        line_color='darkslategray'),
        cells=dict(values=[df2.year, df2.county_name, df2.accidents],fill_color='white',line_color='lightgrey'))
       ])
    fig.update_layout(width=500, height=450)

# Enviar tabla a streamlit
    c1.write(fig)

    
# Generar link de descarga
    c1.markdown(get_table_download_link(df2), unsafe_allow_html=True)


#Descargar datos de vehículos
if c2.checkbox('Obtener datos de vehículos por año y condado', False):

    # Código para generar el DataFrame
    df2 = vh_fn.groupby(['year', 'county_name'])[['accident_id']].count(
    ).reset_index().rename(columns={'accident_id': 'vehicles'})

    # Código para convertir el DataFrame en una tabla plotly resumen
    fig = go.Figure(data=[go.Table(
        header=dict(values=list(df2.columns),
                    fill_color='lightblue',
                    line_color='darkslategray'),
        cells=dict(values=[df2.year, df2.county_name, df2.vehicles], fill_color='white', line_color='lightgrey'))
    ])
    fig.update_layout(width=500, height=450)

# Enviar tabla a streamlit
    c2.write(fig)


# Generar link de descarga
    c2.markdown(get_table_download_link(df2), unsafe_allow_html=True)


#Descargar datos de personas
if c3.checkbox('Obtener datos de personas por año y condado', False):

    # Código para generar el DataFrame
    df2 = pr_fn.groupby(['year', 'county_name'])[['accident_id']].count(
    ).reset_index().rename(columns={'accident_id': 'persons'})

    # Código para convertir el DataFrame en una tabla plotly resumen
    fig = go.Figure(data=[go.Table(
        header=dict(values=list(df2.columns),
                    fill_color='lightblue',
                    line_color='darkslategray'),
        cells=dict(values=[df2.year, df2.county_name, df2.persons], fill_color='white', line_color='lightgrey'))
    ])
    fig.update_layout(width=500, height=450)

# Enviar tabla a streamlit
    c3.write(fig)


# Generar link de descarga
    c3.markdown(get_table_download_link(df2), unsafe_allow_html=True)
