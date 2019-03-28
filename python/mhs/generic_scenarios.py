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
import re
import numpy as np
import json
import sys


from datetime import date
from mhs import Footprint, FootprintSet, Event, EventSet

VERBOSE = True


def verbose_message(msg):
    """
    Display message if we are in verbose mode
    """
    if VERBOSE:
        sys.stderr.write(msg)


class SitesCsv():

    def __init__(self,  idxs=None, coords=None,):
        self.coords = coords
        self.idxs = idxs

    @classmethod
    def from_csv_file(cls, csv_fname):
        """
        :param csv_fname:
        """
        coords = []
        idxs = []
        for i, line in enumerate(open(csv_fname)):
            if i > 0:
                aa = re.split('\,', line)
                coords.append([float(aa[1]), float(aa[2])])
                idxs.append(int(aa[0]))
        print('The file contains {:d} sites'.format(len(idxs)))
        return cls(np.array(idxs), np.array(coords))

    @classmethod
    def empty(cls):
        return cls()


class GmfCsv():
    """
    :param list gmfs:
        A collection of np.arrays
    """
    def __init__():
        # MN ??
        # gmfs = None
        pass

    @classmethod
    def from_csv_file(cls, csv_fname, sites):
        """
        """
        #
        # loading data from the csv file
        data = []
        for i, line in enumerate(open(csv_fname)):
            aa = re.split('\,', line)
            if i == 0:
                labels = aa
            else:
                data.append([d for d in aa])
        data = np.array(data)
        #
        # get the IDs of the gmfs
        gmfids = set(list(data[:, 2]))
        print('The file contains {:d} GMFs'.format(len(gmfids)))
        #
        # storing data for the various IMTs
        gmfs = {}
        footprint_sets = []
        events = []
        for ii, ia in enumerate(range(3, len(labels))):
            # if ii > 0:
            #     continue
            lab = re.sub('^gmv_', '', labels[ia]).strip()
            gmfs[lab] = []
            print(lab)
            footprints = []
            fsid = 'fs{:d}.{:d}'.format(ii+1, len(footprint_sets)+1)

            for igm in gmfids:
                iii = np.nonzero(data[:, 2].astype(int) == int(igm))
                tsit = np.array(data[iii, ia]).T
                tdat = np.squeeze(sites.coords[data[iii, 1].astype(int), :])
                fp_data = np.hstack((tsit, tdat))

                footp = Footprint(fid=igm,
                                  fsid=fsid,
                                  data=fp_data)
                footprints.append(footp)

            print(('Creating FootprintSet fsid={} with {} ' +
                  'footprints for imt={}').format(
                    fsid, lab, len(footprints)))

            fps = FootprintSet(
                event_id='e{:d}'.format(ii+1),
                fsid=fsid,
                imt=lab, process_type='QGM',
                footprints=footprints)
            footprint_sets.append(fps)
            footprints = []

        # TODO load meta-data from a file to replace hard
        # coded values
        event = Event(eid='e{:d}'.format(ii+1),
                      event_set_id='es1',
                      calculation_method='SIM',
                      frequency=1./475.,
                      occurrence_prob=None,
                      occurrence_time_start=None,
                      occurrence_time_end=None,
                      occurrence_time_span=None,
                      trigger_hazard_type=None,
                      trigger_process_type=None,
                      trigger_event_id=None,
                      description='TODO fix me',
                      footprint_sets=footprint_sets)
        events.append(event)
        footprint_sets = []

        # TODO load meta-data from a file to replace hard coded values
        descr = 'Tanzania PGA Hazard Map'
        eventset = EventSet(esid='es1',
                            # geographic_area_bb=[-9., 33., -3., 39.],
                            geographic_area_bb=[80, 30.5, 88.3, 26.25],
                            geographic_area_name='Tanzania',
                            creation_date=date(2018, 9, 11).isoformat(),
                            hazard_type='EQ',
                            time_start=None,
                            time_end=None,
                            time_duration=None,
                            description=descr,
                            bibliography=None,
                            events=events)
        return eventset

    @classmethod
    def _add_fs(cls, event, footprint_set):
        return

    @classmethod
    def _add_events(cls, es, events):
        ii = 0
        for e in events:
            event = Event(eid='e_{:d}'.format(ii+1),
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
            if (fs is not None and len(fs)):
                GmfCsv._add_fs(event, fs)
            es.events.append(event)

    @classmethod
    def from_md(cls, md, sites):
        eventset = EventSet(esid='es_1',
                            geographic_area_bb=md.get('geographic_area_bb'),
                            geographic_area_name=md.get('geographic_area_name'),
                            creation_date=md.get('creation_date'),
                            hazard_type=md.get('hazard_type'),
                            time_start=md.get('time_start'),
                            time_end=md.get('time_end'),
                            time_duration=md.get('time_duration'),
                            description=md.get('description'),
                            bibliography=md.get('bibliography'),
                            events=[])
        events = md.get('events')
        if(events is not None and len(events) > 0):
            GmfCsv._add_events(eventset, events)
        return eventset


def dumper(obj):
    try:
        return obj.as_dict()
    except:
        return obj.__dict__


def read_event_set(md_file):
    """
    Read an EventSet (without footprint values) from meta-data files
    """
    return


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

    es = GmfCsv.from_md(md, None)

    with open('md_out.json', 'w') as fout:
        json.dump(es, fout, default=dumper, indent=2)


if __name__ == "__main__":
    main()
