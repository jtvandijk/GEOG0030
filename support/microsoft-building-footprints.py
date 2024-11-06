# adapted from: https://github.com/microsoft/GlobalMLBuildingFootprints/blob/main/examples/example_building_footprints.ipynb
# conda environment: ms-building

# libraries
import pandas as pd
import geopandas as gpd
from shapely import geometry
import mercantile
from tqdm import tqdm
import os
import tempfile

# bounding box
bbox = {
    "coordinates": [
        [
            [-0.7187188675248422,51.75861859813807],
            [-0.7187188675248422,51.21821068456208],
            [0.49550970655477045,51.21821068456208],
            [0.49550970655477045,51.75861859813807],
            [-0.7187188675248422,51.75861859813807]
        ]
    ],
    "type": "Polygon",
}
bbox_shape = geometry.shape(bbox)
minx, miny, maxx, maxy = bbox_shape.bounds
output_fn = "london-boundingbox.geojson"

# identify tiles
quad_keys = set()
for tile in list(mercantile.tiles(minx, miny, maxx, maxy, zooms=9)):
    quad_keys.add(mercantile.quadkey(tile))
quad_keys = list(quad_keys)
print(f"The input area spans {len(quad_keys)} tiles: {quad_keys}")

# get tile urls
df = pd.read_csv(
    "https://minedbuildings.blob.core.windows.net/global-buildings/dataset-links.csv", dtype=str
)
df.head()

# download tiles
idx = 0
combined_gdf = gpd.GeoDataFrame()
with tempfile.TemporaryDirectory() as tmpdir:
    tmp_fns = []
    for quad_key in tqdm(quad_keys):
        rows = df[df["QuadKey"] == quad_key]
        if rows.shape[0] == 1:
            url = rows.iloc[0]["Url"]

            df2 = pd.read_json(url, lines=True)
            df2["geometry"] = df2["geometry"].apply(geometry.shape)

            gdf = gpd.GeoDataFrame(df2, crs=4326)
            fn = os.path.join(tmpdir, f"{quad_key}.geojson")
            tmp_fns.append(fn)
            if not os.path.exists(fn):
                gdf.to_file(fn, driver="GeoJSON")
        elif rows.shape[0] > 1:
            raise ValueError(f"Multiple rows found for QuadKey: {quad_key}")
        else:
            raise ValueError(f"QuadKey not found in dataset: {quad_key}")

    # merge
    for fn in tmp_fns:
        gdf = gpd.read_file(fn)  
        gdf = gdf[gdf.geometry.within(bbox_shape)] 
        gdf['id'] = range(idx, idx + len(gdf)) 
        idx += len(gdf)
        combined_gdf = pd.concat([combined_gdf,gdf],ignore_index=True)

# save
combined_gdf = combined_gdf.to_crs('EPSG:4326')
combined_gdf.to_file(output_fn, driver='GeoJSON')