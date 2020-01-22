#!
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (c) 2018, GEM Foundation.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.
# If not, see <https://www.gnu.org/licenses/agpl.html>.
#
"""
Import a hazard scenario EventSet into the hazard scenario Database
"""
import sys
from cf_common import License, Contribution
from database import db_connections
import db_settings


VERBOSE = True


def verbose_message(msg):
    """
    Display message if we are in verbose mode
    """
    if VERBOSE:
        sys.stderr.write(msg)


_FOOTPRINT_DATA_QUERY = """
INSERT INTO hazard.footprint_data(
    footprint_id, the_geom, intensity
)
VALUES (
    %s,
    ST_SetSRID(ST_Point(%s,%s),4326),
    %s
)
RETURNING id
"""


_FOOTPRINT_QUERY = """
INSERT INTO hazard.footprint(
    footprint_set_id, uncertainty_2nd_moment, trigger_footprint_id
)
VALUES (%s,%s,%s)
RETURNING id
"""


def _import_footprint(cursor, fsid, fp):
    cursor.execute(_FOOTPRINT_QUERY, [
        fsid,
        fp.data_uncertainty_2nd_moment,
        fp.triggering_footprint_id
    ])
    return cursor.fetchone()[0]


_FOOTPRINT_SET_QUERY = """
INSERT INTO hazard.footprint_set(
    event_id, process_type, imt, data_uncertainty
)
VALUES (%s,%s,%s,%s)
RETURNING id
"""


def _import_footprint_set(cursor, event_id, fs):
    cursor.execute(_FOOTPRINT_SET_QUERY, [
        event_id,
        fs.process_type,
        fs.imt,
        fs.data_uncertainty
    ])
    return cursor.fetchone()[0]


_EVENT_QUERY = """
INSERT INTO hazard.event(
    event_set_id, calculation_method, frequency,
    occurrence_probability, occurrence_time_start,
    occurrence_time_end, occurrence_time_span,
    trigger_hazard_type, trigger_process_type, trigger_event_id,
    description
)
VALUES (
    %s,%s, %s,
    %s,%s,
    %s,%s,
    %s,%s,%s,
    %s
)
RETURNING id
"""


def _import_event(cursor, event_set_id, event):
    cursor.execute(_EVENT_QUERY, [
        event_set_id,
        event.calculation_method,
        event.frequency,
        event.occurrence_prob,
        event.occurrence_time_start,
        event.occurrence_time_end,
        event.occurrence_time_span,
        event.trigger_hazard_type,
        event.trigger_process_type,
        event.trigger_event_id,
        event.description
    ])
    return cursor.fetchone()[0]


_EVENT_SET_QUERY = """
INSERT INTO hazard.event_set(
    the_geom,
    geographic_area_name, creation_date, hazard_type,
    time_start, time_end, time_duration,
    description,bibliography,is_prob
)
VALUES (
    ST_SetSRID(
        ST_MakeBox2D(
            ST_Point(%s,%s),
            ST_Point(%s,%s)
        ),
        4326
    ),
    %s,%s,%s,
    %s,%s,%s,
    %s,%s,%s
)
RETURNING id
"""


def _import_event_set(cursor, es):
    cursor.execute(_EVENT_SET_QUERY, [
        # lon, lat for lower-left
        es.geographic_area_bb[1], es.geographic_area_bb[0],
        # lon, lat for top-right
        es.geographic_area_bb[3], es.geographic_area_bb[2],
        es.geographic_area_name,
        es.creation_date,
        es.hazard_type,
        es.time_start,
        es.time_end,
        es.time_duration,
        es.description,
        es.bibliography,
        es.is_prob
    ])
    return cursor.fetchone()[0]


_FP_DATA_INJECT_QUERY = """
INSERT INTO hazard.footprint_data
    (footprint_id,the_geom,intensity)
    (SELECT %s AS footprint_id, %s)
"""


def _import_footprint_data_via_query(cursor, fpid, data_query, fp):
    query = _FP_DATA_INJECT_QUERY % (fpid, data_query)
    verbose_message("Query = {}".format(query))
    cursor.execute(query)


def _import_footprint_data(cursor, fpid, data):
    # TODO investigate use of cursor.copy_from() and/or batch insert
    for row in data:
        cursor.execute(_FOOTPRINT_DATA_QUERY, [
            fpid,
            # lon, lat
            float(row[1]), float(row[2]),
            # intensity
            row[0]
        ])


def _import_footprints(cursor, fsid, footprints):
    verbose_message("Importing {0} footprints for fsid {1}\n" .format(
        len(footprints), fsid))
    for fp in footprints:
        fpid = _import_footprint(cursor, fsid, fp)
        data_query = fp.directives.get('_cf1_fp_data_query')
        if data_query is None:
            _import_footprint_data(cursor, fpid, fp.data)
        else:
            _import_footprint_data_via_query(cursor, fpid, data_query, fp)


def _import_footprint_sets(cursor, event_id, footprint_sets):
    verbose_message("Importing {0} footprint_sets for event {1}\n" .format(
        len(footprint_sets), event_id))
    for fs in footprint_sets:
        fsid = _import_footprint_set(cursor, event_id, fs)
        _import_footprints(cursor, fsid, fs.footprints)


def _import_events(cursor, event_set_id, events):
    verbose_message("Importing {0} events for event_set {1}\n" .format(
        len(events), event_set_id))
    for event in events:
        verbose_message("Importing event {0}\n" .format(event.eid))
        event_id = _import_event(cursor, event_set_id, event)
        _import_footprint_sets(cursor, event_id, event.footprint_sets)


_CONTRIBUTION_QUERY = """
INSERT INTO hazard.contribution (
    event_set_id, model_source, model_date,
    notes, license_id, version, purpose)
VALUES(
    %s, %s, %s,
    %s, %s, %s, %s
)
"""


def _import_contribution(cursor, event_set_id, cntr):
    if cntr is None:
        return
    contribution = Contribution.from_md(cntr)
    cursor.execute(_CONTRIBUTION_QUERY, [
        event_set_id,
        contribution.model_source,
        contribution.model_date,
        contribution.notes,
        contribution.license_id,
        contribution.version,
        contribution.purpose
    ])


_BB_GEOM_QUERY = """
WITH box AS (
    SELECT ST_SetSRID(ST_Extent(the_geom),4326) AS geom
      FROM hazard.event e
      JOIN hazard.footprint_set fs ON fs.event_id=e.id
      JOIN hazard.footprint fp ON fp.footprint_set_id=fs.id
      JOIN hazard.footprint_data fpd ON fpd.footprint_id=fp.id
     WHERE e.event_set_id=%s)
UPDATE hazard.event_set SET the_geom = box.geom FROM box WHERE id=%s
"""


def _fix_bb_geometry(cursor, event_set_id):
    """
    Update the event_set bounding_box to the bounding box extent of all
    footprint data point in the event_set
    """
    cursor.execute(_BB_GEOM_QUERY, [event_set_id, event_set_id])


def import_event_set(es):
    """
    Import data from a scenario EventSet
    """
    verbose_message("Model contains {0} events\n" .format(len(es.events)))

    connections = db_connections(db_settings.db_confs)

    with connections['hazard_contrib'].cursor() as cursor:
        License.load_licenses(cursor)
        # TODO investigate commit/rollback
        event_set_id = _import_event_set(cursor, es)
        _import_contribution(cursor, event_set_id, es.contribution)
        verbose_message('Inserted event_set, id={0}\n'.format(event_set_id))
        _import_events(cursor, event_set_id, es.events)
        verbose_message('Updating bounding box\n')
        _fix_bb_geometry(cursor, event_set_id)
        return event_set_id
