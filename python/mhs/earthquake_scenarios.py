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

from datetime import date
from mhs import Footprint, FootprintSet, Event, EventSet


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

            print(('EOL Creating FootprintSet fsid={} with {} ' +
                  'footprints for imt={}').format(
                    fsid, lab, len(footprints)))

            fps = FootprintSet(
                event_id='e{:d}'.format(ii+1),
                fsid=fsid,
                imt=lab, process_type='e-gm',
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
                          trigger_peril_type=None,
                          trigger_process_type=None,
                          trigger_event_id=None,
                          description='Test footprints',
                          footprint_sets=footprint_sets)
            events.append(event)
            footprint_sets = []

        # TODO load meta-data from a file to replace hard coded values
        descr = 'Sample scenarios for Dodoma, Tanzania'
        eventset = EventSet(esid='es1',
                            geographic_area_bb=[-9., 33., -3., 39.],
                            geographic_area_name='Dodoma, Tanzania',
                            creation_date=date(2018, 1, 30).isoformat(),
                            hazard_type='EQK',
                            time_start=None,
                            time_end=None,
                            time_duration=None,
                            description=descr,
                            bibliography=None,
                            events=events)
        return eventset


def dumper(obj):
    try:
        return obj.as_dict()
    except:
        return obj.__dict__


def read_event_set(site_file, gmf_file):
    """
    Read an EventSet from site and GMF CSV files
    """
    sites = SitesCsv.from_csv_file(site_file)
    return GmfCsv.from_csv_file(gmf_file, sites)


def main():
    site_file = './../../scenarios/Earthquakes/20180117/sitemesh-_17001.csv'
    gmf_file = './../../scenarios/Earthquakes/20180117/gmf-data_17001.csv'
    es = read_event_set(site_file, gmf_file)

    with open('sample.json', 'w') as fout:
        json.dump(es, fout, default=dumper, indent=2)


if __name__ == "__main__":
    main()
