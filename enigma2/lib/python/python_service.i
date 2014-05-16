%{
#include <lib/python/swig.h>
#include <lib/python/python_helpers.h>
%}

%extend iServiceInformation {
PyObject *getInfoObject(int w)
{
	switch (w)
	{
		case iServiceInformation::sTransponderData:
		{
			ePyObject ret = PyDict_New();
			if (ret)
			{
				ePtr<iDVBTransponderData> data = self->getTransponderData();
				if (data)
				{
					transponderDataToDict(ret, data);
				}
			}
			return ret;
		}
		case iServiceInformation::sFileSize:
			return PyLong_FromLongLong(self->getFileSize());
		case iServiceInformation::sCAIDs:
		{
			ePyObject ret;
			std::vector<int> caids, ecmpids;
			self->getCaIds(caids, ecmpids);
			int cnt = caids.size();

			ret = PyList_New(cnt);

			for (unsigned int i = 0; i < cnt; i++)
			{
				PyList_SET_ITEM(ret, i, PyInt_FromLong(caids[i]));
			}
			return ret;
		}
		case iServiceInformation::sCAIDPIDs:
		{
			ePyObject ret;
			std::vector<int> caids, ecmpids;
			self->getCaIds(caids, ecmpids);
			int cnt = caids.size();

			ret = PyList_New(cnt);

			for (unsigned int i = 0; i < cnt; i++)
			{
				ePyObject tuple = PyTuple_New(2);
				PyTuple_SET_ITEM(tuple, 0, PyInt_FromLong(caids[i]));
				PyTuple_SET_ITEM(tuple, 1, PyInt_FromLong(ecmpids[i]));
				PyList_SET_ITEM(ret, i, tuple);
			}
			return ret;
		}
	}
	Py_INCREF(Py_None);
	return Py_None;
}

PyObject *getAITApplications()
{
	ePyObject tuple = PyTuple_New(2);
	std::map<int, std::string> aitlist;
	self->getAITApplications(aitlist);
	if (!aitlist.empty())
	{
		ePyObject l = PyList_New(0);
		for (std::map<int, std::string>::iterator it=aitlist.begin(); it!=aitlist.end(); ++it)
		{
			ePyObject tuple = PyTuple_New(2);
			PyTuple_SET_ITEM(tuple, 0, PyInt_FromLong(it->first));
			PyTuple_SET_ITEM(tuple, 1, PyString_FromString(it->second.c_str()));
			PyList_Append(l, tuple);
			Py_DECREF(tuple);
		}
		return l;
	}
	Py_INCREF(Py_None);
	return Py_None;
}
};

%ignore iServiceInformation::getInfoObject;

%extend iStaticServiceInformation {
PyObject *getInfoObject(const eServiceReference &ref, int w)
{
	switch (w)
	{
		case iServiceInformation::sTransponderData:
		{
			ePyObject ret = PyDict_New();
			if (ret)
			{
				ePtr<iDVBTransponderData> data = self->getTransponderData(ref);
				if (data)
				{
					transponderDataToDict(ret, data);
				}
			}
			return ret;
		}
		case iServiceInformation::sFileSize:
			return PyLong_FromLongLong(self->getFileSize(ref));
	}
	Py_INCREF(Py_None);
	return Py_None;
}
};

%ignore iStaticServiceInformation::getInfoObject;

%extend iStreamableService {
PyObject *getStreamingData()
{
	ePtr<iStreamData> data = self->getStreamingData();
	if (data)
	{
		ePyObject ret = PyDict_New();
		streamingDataToDict(ret, data);
		return ret;
	}
	Py_INCREF(Py_None);
	return Py_None;
}
};

%ignore iStreamableService::getStreamingData;

%extend iFrontendInformation {
PyObject *getFrontendData()
{
	ePyObject ret = PyDict_New();
	if (ret)
	{
		ePtr<iDVBFrontendData> data = self->getFrontendData();
		if (data)
		{
			frontendDataToDict(ret, data);
		}
	}
	return ret;
}

PyObject *getFrontendStatus()
{
	ePyObject ret = PyDict_New();
	if (ret)
	{
		ePtr<iDVBFrontendStatus> status = self->getFrontendStatus();
		if (status)
		{
			frontendStatusToDict(ret, status);
		}
	}
	return ret;
}

PyObject *getTransponderData(bool original)
{
	ePyObject ret = PyDict_New();
	if (ret)
	{
		ePtr<iDVBTransponderData> data = self->getTransponderData(original);
		if (data)
		{
			transponderDataToDict(ret, data);
		}
	}
	return ret;
}

PyObject *getAll(bool original)
{
	ePyObject ret = PyDict_New();
	if (ret)
	{
		ePtr<iDVBFrontendData> data = self->getFrontendData();
		if (data)
		{
			frontendDataToDict(ret, data);
		}
		ePtr<iDVBFrontendStatus> status = self->getFrontendStatus();
		if (status)
		{
			frontendStatusToDict(ret, status);
		}
		ePtr<iDVBTransponderData> tpdata = self->getTransponderData(original);
		if (tpdata)
		{
			transponderDataToDict(ret, tpdata);
		}
	}
	return ret;
}
};

%extend iSubtitleOutput {
RESULT enableSubtitles(eWidget *parent, PyObject *tuple)
{
	eSubtitleWidget *widget = NULL;
	struct iSubtitleOutput::SubtitleTrack track;
	track.type = 0;
	track.pid = -1;
	track.page_number = 0;
	track.magazine_number = 0;

	if (PyTuple_Check(tuple))
	{
		ePyObject entry;
		int tuplesize = PyTuple_Size(tuple);
		if (tuplesize < 1)
			goto error_out;

		entry = PyTuple_GET_ITEM(tuple, 0);

		if (!PyInt_Check(entry))
			goto error_out;

		track.type = PyInt_AsLong(entry);

		entry = PyTuple_GET_ITEM(tuple, 1);
		if (!PyInt_Check(entry))
			goto error_out;
		track.pid = PyInt_AsLong(entry);

		entry = PyTuple_GET_ITEM(tuple, 2);
		if (PyInt_Check(entry))
		{
			track.page_number = PyInt_AsLong(entry);
		}

		entry = PyTuple_GET_ITEM(tuple, 3);
		if (PyInt_Check(entry))
		{
			track.magazine_number = PyInt_AsLong(entry);
		}
	}

	widget = new eSubtitleWidget(parent);
	widget->resize(parent->size()); /* full size */

	if (self->enableSubtitles(widget, track) >= 0)
	{
		return 0;
	}
error_out:
	return -1;
}

RESULT disableSubtitles(eWidget *parent)
{
	return self->disableSubtitles();
}

PyObject *getSubtitleList()
{
	std::vector<struct iSubtitleOutput::SubtitleTrack> subtitlelist;
	if (self->getSubtitleList(subtitlelist) >= 0)
	{
		ePyObject l = PyList_New(0);
		for (unsigned int i = 0; i < subtitlelist.size(); i++)
		{
			ePyObject tuple = PyTuple_New(5);
			PyTuple_SET_ITEM(tuple, 0, PyInt_FromLong(subtitlelist[i].type));
			PyTuple_SET_ITEM(tuple, 1, PyInt_FromLong(subtitlelist[i].pid));
			PyTuple_SET_ITEM(tuple, 2, PyInt_FromLong(subtitlelist[i].page_number));
			PyTuple_SET_ITEM(tuple, 3, PyInt_FromLong(subtitlelist[i].magazine_number));
			PyTuple_SET_ITEM(tuple, 4, PyString_FromString(subtitlelist[i].language_code.c_str()));
			PyList_Append(l, tuple);
			Py_DECREF(tuple);
		}
		return l;
	}
	Py_INCREF(Py_None);
	return Py_None;
}

PyObject *getCachedSubtitle()
{
	struct iSubtitleOutput::SubtitleTrack track;
	if (self->getCachedSubtitle(track) >= 0)
	{
		ePyObject tuple = PyTuple_New(4);
		PyTuple_SET_ITEM(tuple, 0, PyInt_FromLong(track.type));
		PyTuple_SET_ITEM(tuple, 1, PyInt_FromLong(track.pid));
		PyTuple_SET_ITEM(tuple, 2, PyInt_FromLong(track.page_number));
		PyTuple_SET_ITEM(tuple, 3, PyInt_FromLong(track.magazine_number));
		return tuple;
	}
	Py_INCREF(Py_None);
	return Py_None;
}
};

%ignore iSubtitleOutput::enableSubtitles;
%ignore iSubtitleOutput::disableSubtitles;
%ignore iSubtitleOutput::getSubtitleList;
%ignore iSubtitleOutput::getCachedSubtitle;
%ignore iSubtitleOutput::SubtitleTrack;

%ignore iFrontendInformation::getFrontendData;
%ignore iFrontendInformation::getFrontendStatus;
%ignore iFrontendInformation::getTransponderData;
%ignore iFrontendInformation::getAll;

%ignore iStreamData;
%ignore iDVBFrontendStatus;
%ignore iDVBTransponderData;
%ignore iDVBFrontendData;
%ignore iStreamBufferInfo;
