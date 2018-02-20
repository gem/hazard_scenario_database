#!/usr/bin/env python3
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

from django.db import connections
from django.conf import settings
from mhs import Footprint, FootprintSet, Event, EventSet
from earthquake_scenarios import read_event_set

import db_settings
settings.configure(DATABASES=db_settings.DATABASES)

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
    %s.
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
    event_set_id, frequency,
    occurrence_probability, occurrence_time_start,
    occurrence_time_end, occurrence_time_span,
    trigger_hazard_type, trigger_process_type, trigger_event_id,
    description
)
VALUES (
    %s,%s,
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
        event.frequency,
        event.occurrence_probability,
        event.occurrence_time_start,
        event.occurrence_time_end,
        event.occurrence_time_span,
        event.trigger_hazard_type,
        event.trigger_process_type,
        event.trigger_event_id,
        description
    ])
    return cursor.fetchone()[0]


_EVENT_SET_QUERY = """
INSERT INTO hazard.event_set(
    the_geom,
    geographic_area_name, creation_date, hazard_type,
    time_start, time_end, time_duration,
    description,bibliography
)
VALUES (
    ST_SetSRID(ST_MakeBox2D(%s,%s,%s,%s),4326),
    %s,%s,%s,
    %s,%s,%s,
    %s,%s
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
        hazard_type,
        time_start,
        time_end,
        time_duration,
        description,
        bibliography
    ])
    return cursor.fetchone()[0]


def _import_footprint_data(cursor, fpid, data):
    # TODO investigate use of cursor.copy_from() and/or batch insert
    for row in data:
        cursor.execute(_FOOTPRINT_DATA_QUERY, [
            fpid,
            # lon, lat
            row[2], row[1],
            # intensity
            row[0]
        ])


def _import_footprints(cursor, fsid, footprints):
    for fp in footprints:
        fpid = _import_footprint(cursor, fsid, fp)
        _import_footprint_data(cursor, fpid, fp.data)


def _import_footprint_sets(cursor, event_id, footprint_sets):
    for fs in footprint_sets:
        fsid = _import_footprint_set(cursor, event_id, footprint_set)
        _import_footprints(cursor, fsid, fs.footprints)


def _import_events(cursor, event_set_id, events):
    for event in events:
        event_id = _import_event(cursor, event_set_id, event)
        _import_footprint_sets(cursor, event_id, event.footprint_sets)


def import_event_set(es):
    """
    Import data from a scenario EventSet
    """
    verbose_message("Model contains {0} events\n" .format(len(es.events)))

    with connections['hazard_contrib'].cursor() as cursor:
        # TODO investigate commit/rollback
        event_set_id = _import_event_set(cursor, es)
        # _import_contribution(cursor, ex, model_id)
        verbose_message('Inserted event_set, id={0}\n'.format(model_id))
        _import_events(cursor, event_set_id, es.events)
        return model_id


def main():
    site_file = './../../scenarios/Earthquakes/20180117/sitemesh-_17001.csv'
    gmf_file = './../../scenarios/Earthquakes/20180117/gmf-data_17001.csv'
    verbose_message("Reading CSV files {0} and {1}\n".format(
        site_file, gmf_file))
    es = read_event_set(site_file, gmf_file)
    imported_id = import_event_set(es)
    sys.stderr.write("Imported scenario DB id = {0}\n".format(imported_id))

if __name__ == "__main__":
    main()
