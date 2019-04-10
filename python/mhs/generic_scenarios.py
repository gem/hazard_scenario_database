#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (c) 2019, GEM Foundation.
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
import json
import sys

from mhs import Footprint, FootprintSet, Event, EventSet

from import_scenarios import import_event_set


VERBOSE = True


def verbose_message(msg):
    """
    Display message if we are in verbose mode
    """
    if VERBOSE:
        sys.stderr.write(msg)


class JSONEventSet():
    """
    Read meta-data for EventSets from JSON
    """
    def __init__():
        pass

    @classmethod
    def _add_footprints(cls, footprint_set, footprints):
        i = 0
        for fp_md in footprints:
            fpid = 'fp_{}.{:d}'.format(footprint_set.fsid, i)
            footprint = Footprint(
                fpid, footprint_set.fsid, [], directives=fp_md)
            footprint_set.footprints.append(footprint)
            i = i + 1

    @classmethod
    def _add_fs(cls, event, footprint_sets):
        jj = 0
        for fs in footprint_sets:
            fsid = 'fs_{}.{:d}'.format(event.eid, jj)
            fps = FootprintSet(
                event_id=event.eid,
                fsid=fsid,
                imt=fs.get('imt'),
                process_type=fs.get('process_type'),
                footprints=[])
            f = fs.get('footprints')
            if f is not None and len(f) > 0:
                JSONEventSet._add_footprints(fps, f)
            event.footprint_sets.append(fps)
            jj = jj + 1

    @classmethod
    def _add_events(cls, es, events):
        for i, e in enumerate(events):
            event = Event(eid='e_{:d}'.format(i+1),
                          event_set_id=es.esid,
                          calculation_method=e.get('calculation_method'),
                          frequency=e.get('frequency'),
                          occurrence_prob=e.get('occurence_prob'),
                          occurrence_time_start=e.get('occurrence_time_start'),
                          occurrence_time_end=e.get('occurrence_time_end'),
                          occurrence_time_span=e.get('occurrence_time_span'),
                          trigger_hazard_type=e.get('trigger_hazard_type'),
                          trigger_process_type=e.get('trigger_process_type'),
                          trigger_event_id=e.get('trigger_process_type'),
                          description=e.get('description'),
                          footprint_sets=[])
            fs = e.get('footprint_sets')
            if (fs is not None and len(fs) > 0):
                JSONEventSet._add_fs(event, fs)
            es.events.append(event)

    @classmethod
    def from_md(cls, md):
        """
        Read an EventSet (without footprint values) from meta-data files
        """
        eventset = EventSet(esid='es_1',
                            geographic_area_bb=md.get('geographic_area_bb'),
                            geographic_area_name=md.get(
                                'geographic_area_name'),
                            creation_date=md.get('creation_date'),
                            hazard_type=md.get('hazard_type'),
                            time_start=md.get('time_start'),
                            time_end=md.get('time_end'),
                            time_duration=md.get('time_duration'),
                            description=md.get('description'),
                            bibliography=md.get('bibliography'),
                            is_prob=md.get('is_prob'),
                            events=[])
        eventset.contribution = md.get('contribution')
        events = md.get('events')
        if events is not None and len(events) > 0:
            JSONEventSet._add_events(eventset, events)
        return eventset


def dumper(obj):
    try:
        return obj.as_dict()
    except AttributeError:
        return obj.__dict__


def main():
    if len(sys.argv) != 2:
        sys.stderr.write('Usage {0} meta-data\n'.format(
            sys.argv[0]))
        exit(1)

    md_file = sys.argv[1]

    verbose_message("Reading meta-data file {0}\n".format(
        md_file))

    md = {}
    with open(md_file, 'r') as fin:
        md = json.load(fin)

    es = JSONEventSet.from_md(md)

    with open('md_out.json', 'w') as fout:
        json.dump(es, fout, default=dumper, indent=2)

    verbose_message("Importing event set")
    imported_id = import_event_set(es)

    sys.stderr.write("Imported scenario DB id = {0}\n".format(imported_id))

if __name__ == "__main__":
    main()
