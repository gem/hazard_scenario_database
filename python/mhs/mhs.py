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

#
# TODO check lists of valid values, ensure they match doc and SQL schema
#
HAZARD_TYPES = [
    'earthquake', 'flood', 'landslide', 'storm_surge', 'tsunami',
    'volcano'
]

PROCESS_TYPE = {'earthquake': ['ground shaking', 'primary_surface_rupture',
                               'secondary_surface_rupture', 'liquefaction'],
                'flood': ['inundation'],
                'landslide': ['fall', 'topple', 'slide', 'lateral_spread',
                              'flow', 'complex'],
                'storm_surge': ['inundation'],
                'volcano': ['ash_fall', 'airborne_ash', 'lahar', 
                            'tephra_load']}


class EventSet():
    """
    Event Set

    :param eisd:
    :param geographic_area_bb:
    :param geographic_area_name:
    :param creation_date:
    :param hazard_type:
    :param time_start:
        ISO 8601 formatted
    :param time_end:
        ISO 8601 formatted
    :param str time_duration:
        ISO 8601 formatted
    :param str description:
    :param str bibliography:
    """

    def __init__(self, esid, geographic_area_bb, geographic_area_name,
                 creation_date, hazard_type, time_start=None,
                 time_end=None, time_duration=None, description=None,
                 bibliography=None, events=None):
        self.esid = esid
        self.geographic_area_bb = geographic_area_bb
        self.geographic_area_name = geographic_area_name
        self.creation_date = creation_date
        self.hazard_type = hazard_type
        self.time_start = time_start
        self.time_end = time_end
        self.time_duration = time_duration
        self.description = description
        self.bibliography = bibliography
        self.events = events


class Event():
    """
    Event
    """

    def __init__(self, eid, event_set_id, calculation_method=None,
                 frequency=None, occurrence_prob=None,
                 occurrence_time_start=None, occurrence_time_end=None,
                 occurrence_time_span=None, trigger_hazard_type=None,
                 trigger_process_type=None, trigger_event_id=None,
                 description=None, footprint_sets=None):
        """
        :param list footprint_sets:
        """
        self.eid = eid
        self.event_set_id = event_set_id
        self.calculation_method = calculation_method
        self.frequency = frequency,
        self.occurrence_prob = occurrence_prob,
        self.occurrence_time_start = occurrence_time_start,
        self.occurrence_time_end = occurrence_time_end,
        self.occurrence_time_span = occurrence_time_span,
        self.trigger_hazard_type = trigger_hazard_type,
        self.trigger_process_type = trigger_process_type,
        self.trigger_event_id = trigger_event_id,
        self.description = description
        self.footprint_sets = footprint_sets


class FootprintSet():
    """
    FootprintSet

    :param str fsid:
        FootprintSet ID
    :param str event_id:
        String identifying the corresponding event
    :param str imt:
        The string defining the intensity measure type
    :param str process_type:
        The key describing the typology of process modelled (e.g. ground
        motion)
    :param list footprints
    :param data_uncertainty
    """
    def __init__(self, fsid, event_id, imt, process_type,
                 footprints,
                 data_uncertainty=None):
        self.fsid = fsid
        self.imt = imt
        self.process_type = process_type
        self.data_uncertainty = data_uncertainty
        self.footprints = footprints


class Footprint():
    """
    Footprint

    :param str fid:
        Footprint ID
    :param str fsid:
        String identifying the corresponding footprint set
    :param data:
        A :class:`numpy.ndarray` instance
    :param data_uncertainty_2nd_moment:
    :param triggering_footprint_id:
    """

    def __init__(self, fid, fsid, data,
                 data_uncertainty_2nd_moment=None,
                 triggering_footprint_id=None):
        self.fid = fid
        self.fsid = fsid
        self.data = data
        self.data_uncertainty_2nd_moment = data_uncertainty_2nd_moment
        self.triggering_footprint_id = triggering_footprint_id

    def as_dict(self):
        ret = self.__dict__
        ret['data'] = self.data.tolist()
        for r, tri in enumerate(ret['data']):
            for k, v in enumerate(tri):
                ret['data'][r][k] = float(v)
        return ret
