PERIL_TYPES = ['earthquake', 'flood', 'landslide', 'storm_surge', 'tsunami',
               'volcano']

PROCESS_TYPE = {'earthquake': ['ground shaking', 'primary_surface_rupture',
                               'secondary_surface_rupture', 'liquefaction'],
                'flood': ['inundation'],
                'landslide': ['fall', 'topple', 'slide', 'lateral_spread',
                              'flow', 'complex'],
                'storm_surge': ['inundation'],
                'volcano': ['ash_fall', 'airborne_ash', 'lahar']}


class EventSet():
    """
    Event Set

    :param eisd:
    :param geographic_area_bb:
    :param geographic_area_name:
    :param creation_date:
    :param peril_type:
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
                 creation_date, peril_type, time_start=None,
                 time_end=None, time_duration=None, description=None,
                 bibliography=None, events=None):
        self.esid = esid
        self.geographic_area_bb = geographic_area_bb
        self.geographic_area_name = geographic_area_name
        self.creation_date = creation_date
        self.peril_type = peril_type
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

    def __init__(self, eid, scenario_set_id, calculation_method=None,
                 frequency=None, occurrence_prob=None,
                 occurrence_time_start=None, occurrence_time_end=None,
                 occurrence_time_span=None, trigger_peril_type=None,
                 trigger_process_type=None, trigger_event_id=None,
                 description=None, footprints=None):
        """
        :param list footprints:
        """
        self.eid = eid
        self.scenario_set_id = scenario_set_id
        self.calculation_method = calculation_method
        self.frequency = frequency,
        self.occurrence_prob = occurrence_prob,
        self.occurrence_time_start = occurrence_time_start,
        self.occurrence_time_end = occurrence_time_end,
        self.occurrence_time_span = occurrence_time_span,
        self.trigger_peril_type = trigger_peril_type,
        self.trigger_process_type = trigger_process_type,
        self.trigger_event_id = trigger_event_id,
        self.description = description
        self.footprints = footprints


class Footprint():
    """
    Footprint

    :param str fid:
        Footprint ID
    :param str event_id:
        String identifying the corresponding event
    :param data:
        A :class:`numpy.ndarray` instance
    :param str imt:
        The string defining the intensity measure type
    :param str process_type:
        The key describing the typology of process modelled (e.g. ground
        motion)
    :param data_uncertainty_distribution:
    :param data_uncertainty_2nd_moment:
    :param data_uncertainty_values:
    :param triggering_footprint_id:
    """

    def __init__(self, fid, event_id, data, imt, process_type,
                 data_uncertainty_distribution, data_uncertainty_2nd_moment,
                 data_uncertainty_values, triggering_footprint_id):
        self.fid = fid
        self.event_id = event_id
        self.data = data
        self.imt = imt
        self.process_type = process_type
        self.data_uncertainty_distribution = data_uncertainty_distribution
        self.data_uncertainty_2nd_moment = data_uncertainty_2nd_moment
        self.data_uncertainty_values = data_uncertainty_values
        self.triggering_footprint_id = triggering_footprint_id

    def as_dict(self):
        ret = self.__dict__
        ret['data'] = self.data.tolist()
        return ret
