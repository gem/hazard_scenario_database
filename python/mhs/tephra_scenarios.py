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
import re
import numpy as np
import json
import os

from datetime import date
from mhs import Footprint, FootprintSet, Event, EventSet
from import_scenarios import import_event_set

# Frequency of tephra events
FMAP = {
    'VEI2': 1/450.0,
    'VEI4': 1/700.0,
    'VEI6': 1/3000.0
}


class TephraOut():

    def __init__(self,  data=None):
        self.data = data

    @classmethod
    def from_out_file(cls, out_fname):
        """
        :param out_fname:
        """
        data = []
        for i, line in enumerate(open(out_fname)):
            aa = re.split(' ', line)
            data.append([float(aa[2]), float(aa[0]), float(aa[1])])

        print('{:s} contains {:d} points'.format(out_fname, len(data)))
        return cls(np.array(data))


def dumper(obj):
    try:
        return obj.as_dict()
    except:
        return obj.__dict__


def build_event(ed, tephra_dir, ii):
    event_type = re.sub(r'^[^_]*\_', '', ed)
    f = FMAP[event_type]
    print('ed is of event type {0}, frequency {1}'.format(event_type, f))

    footprints = []
    ev_dir = os.path.join(tephra_dir, ed)
    # TODO use 1, 1000 when ready
    for i in range(1, 3):
        fpf = os.path.join(ev_dir, str(i), 'out_0001.out')
        out = TephraOut.from_out_file(fpf)
        fp = Footprint(fid=str(i),
                       fsid=event_type,
                       data=out.data)
        footprints.append(fp)

    fps = FootprintSet(
                event_id='e{:d}'.format(ii+1),
                fsid='fs{:d}'.format(ii+1),
                imt='tephra_load', process_type='v-tl',
                footprints=footprints)

    event = Event(eid='e{:d}'.format(ii+1),
                      event_set_id='tephra_es1',
                      calculation_method='SIM',
                      frequency=f,
                      occurrence_prob=None,
                      occurrence_time_start=None,
                      occurrence_time_end=None,
                      occurrence_time_span=None,
                      trigger_hazard_type=None,
                      trigger_process_type=None,
                      trigger_event_id=None,
                      description=ed,
                      footprint_sets=[fps])
    return event


def read_event_set(tephra_dir):
    """
    Read an EventSet from Tephra out files
    """
    events = []

    event_dirs = os.listdir(tephra_dir)
    ii = 0
    for ed in event_dirs:
        events.append(build_event(ed, tephra_dir, ii))
        ii = ii + 1

    # TODO load meta-data from a file to replace hard coded values
    descr = 'Tephra load scenarios for Rungwe, Tanzania'

    event_set = EventSet(esid='tephra_es1',
                         geographic_area_bb=[-9., 33., -3., 39.],
                         geographic_area_name='Rungwe, Tanzania',
                         creation_date=date(2018, 1, 30).isoformat(),
                         hazard_type='VOL',
                         time_start=None,
                         time_end=None,
                         time_duration=None,
                         description=descr,
                         bibliography=None,
                         events=events)
    return event_set


def main():
    tephra_dir = '../../scenarios/Volcanoes/Rungwe_tephra-fall-footprints'
    es = read_event_set(tephra_dir)

    with open('tephra.json', 'w') as fout:
        json.dump(es, fout, default=dumper, indent=2)

    import_event_set(es)

if __name__ == "__main__":
    main()
