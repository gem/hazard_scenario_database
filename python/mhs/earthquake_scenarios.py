#!/usr/bin/env python3
import re
import numpy as np
import json

from datetime import date
from mhs import Footprint, Event, EventSet


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
        for ii, ia in enumerate(range(3, len(labels))):
            # if ii > 0:
            #     continue
            lab = re.sub('^gmv_', '', labels[ia])
            gmfs[lab] = []
            print(lab)
            footprints = []
            for igm in gmfids:
                iii = np.nonzero(data[:, 2].astype(int) == int(igm))
                tsit = np.array(data[iii, ia]).T
                tdat = np.squeeze(sites.coords[data[iii, 1].astype(int), :])
                xxx = np.hstack((tsit, tdat))
                footp = Footprint(fid=igm,
                                  event_id='e{:d}'.format(ii+1),
                                  data=xxx,
                                  imt=lab,
                                  process_type='e-gm',
                                  data_uncertainty_distribution=None,
                                  data_uncertainty_2nd_moment=None,
                                  data_uncertainty_values=None,
                                  triggering_footprint_id=None)
                footprints.append(footp)

            event = Event(eid='e{:d}'.format(ii+1),
                          scenario_set_id='es1',
                          calculation_method='simulated',
                          frequency=1./475.,
                          occurrence_prob=None,
                          occurrence_time_start=None,
                          occurrence_time_end=None,
                          occurrence_time_span=None,
                          trigger_peril_type=None,
                          trigger_process_type=None,
                          trigger_event_id=None,
                          description='Test footprints',
                          footprints=footprints)

        descr = 'Sample scenarios for Dodoma, Tanzania'
        eventset = EventSet(esid='es1',
                            geographic_area_bb=[-9., 33., -3., 39.],
                            geographic_area_name='Dodoma, Tanzania',
                            creation_date=date(2018, 1, 30).isoformat(),
                            peril_type='earthquake',
                            time_start=None,
                            time_end=None,
                            time_duration=None,
                            description=descr,
                            bibliography=None,
                            events=[event])
        return eventset


def dumper(obj):
    try:
        return obj.as_dict()
    except:
        return obj.__dict__


def main():

    fname = './../../scenarios/Earthquakes/20180117/sitemesh-_17001.csv'
    sites = SitesCsv.from_csv_file(fname)

    fname = './../../scenarios/Earthquakes/20180117/gmf-data_17001.csv'
    es = GmfCsv.from_csv_file(fname, sites)

    with open('sample.json', 'w') as fout:
        json.dump(es, fout, default=dumper, indent=2)


if __name__ == "__main__":
    main()
