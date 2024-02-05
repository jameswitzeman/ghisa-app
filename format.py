#Formatting
import pandas as pd
import numpy as np
import geopy
import geemap
import ee
import config
import jinja2
import hvplot.pandas
import holoviews as hv
import geopandas as gpd
import geoviews as gv
import panel as pn

print("Loading Hyperion data...")

#Begin importing data

  #GHISA-CONUS-2008 data
core_data = pd.read_csv(r'/LPDAAC/GHISACONUS_2008_001_speclib.csv',
                     low_memory=False, index_col=False, na_values='NaN') 
  #GHISA-CASIA data

print("Loaded ASD / Hyperion data.\n")
  #PRISMA data
prisma_data = pd.read_csv(r'/LPDAAC/prisma_data.csv',
                     low_memory=False, index_col=False, na_values='NaN')

print("Loaded PRISMA data.\n")
  #DESIS data
desis_data = pd.read_csv(r'/LPDAAC/desis_data.csv', 
                     low_memory=False, index_col=False, na_values='NaN')

print("Loaded DESIS data.\n")

#Dict for renaming all the prisma/desis columns.
to_rename = {'JD' : 'JulianDay',
             'Longitude' : 'Long',
             'Latitude' : 'Lat',
             'Crop Type' : 'Crop',
             'GAEZ' : 'AEZ',
             'Image ID' : 'Image',
             'Unique ID' : 'UniqueID'
             }

    #Rename each column properly
core_data.rename(columns={'jd' : 'JulianDay'}, inplace=True)
core_data.rename(columns={"long" : "Long", "lat" : "Lat"}, inplace=True)
desis_data.rename(columns=to_rename, inplace = True)
prisma_data.rename(columns=to_rename, inplace = True)

core_data.rename(columns={"long" : "Long", "lat" : "Lat"}, inplace=True)

    #Convert month number to name
month_labels = {1: 'January', 2: 'February', 3: 'March', 4: 'April', 5: 'May',
                6: 'June', 7: 'July', 8: 'August',
                9: 'September', 10: 'October', 11: 'November', 12: 'December'}

core_data['Month'] = core_data['Month'].astype(int);
core_data['Month'] = core_data['Month'].apply(lambda x: month_labels[x])
    #Add sensor data for Hyperion data
core_data.insert(0, "Sensor", 'Hyperion')

    #Merge prisma and desis, capitalize months
desis_data = desis_data.merge(prisma_data, how='outer')
desis_data['Month'] = desis_data['Month'].str.capitalize()
print(desis_data)

    #Merge prisma/desis and hyperion
core_data = core_data.merge(desis_data, how='outer')

# Formatting
core_data['Month'] = core_data['Month'].replace(['NA'], 0)
core_data['Month'] = core_data['Month'].fillna(0)

core_data['JulianDay'] = core_data['JulianDay'].replace(['NA'], 0)
core_data['JulianDay'] = core_data['JulianDay'].fillna(0)

core_data['Crop'] = core_data['Crop'].str.capitalize()

core_data['Year'] = core_data['Year'].replace(['NA'], 2011)
core_data['Year'] = core_data['Year'].fillna(2011)
core_data['Year'] = core_data['Year'].astype(int);

core_data['Sensor'] = core_data['Sensor'].replace(['ASD'], 'ASD Spectroradiometer')


core_data = core_data.convert_dtypes()

#Give a master ID to the whole dataframe
core_data.insert(0, 'MasterID', range(0, 0 + len(core_data)))

#Get the names of all the columns to unpivot
names = []
for i, c in core_data.items():
    if c.name[0] == 'X':
        names.append(c.name)

#Unpivot columns
data_flipped = core_data.melt(value_vars=names, id_vars='MasterID', var_name='Wavelength', value_name='Reflectance')

#Get rid of the redundant wavelength columns
core_data = core_data.drop(labels=names, axis='columns')

#Merge the pivoted frame with the original frame
data_flipped = pd.merge(core_data, data_flipped)
core_data = data_flipped

#Get rid of the leading 'X' and convert all the number strings to ints
core_data['Wavelength'] = core_data['Wavelength'].map(lambda x: x.lstrip('X'))
core_data['Wavelength'] = core_data['Wavelength'].astype(float)

print("All data ready.")
print(core_data)
core_data.to_csv("core_data-long.csv", index = False)
