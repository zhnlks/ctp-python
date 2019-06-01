%module(directors="1") ctp

%include "typemaps.i"

//%begin %{
//#define SWIG_PYTHON_STRICT_BYTE_CHAR
//%}

%{
#define SWIG_FILE_WITH_INIT
#include "ThostFtdcUserApiDataType.h"
#include "ThostFtdcUserApiStruct.h"
#include "ThostFtdcMdApi.h"
#include "ThostFtdcTraderApi.h"
#include "iconv.h"
%}

%feature("director:except") {
    if ($error != NULL) {
        PyObject *exc, *val, *tb;
        PyErr_Fetch(&exc, &val, &tb);
        PyErr_NormalizeException(&exc, &val, &tb);
        std::string err_msg("In method '$symname': ");

        PyObject* exc_str = PyObject_GetAttrString(exc, "__name__");
        err_msg += PyUnicode_AsUTF8(exc_str);
        Py_XDECREF(exc_str);

        if (val != NULL)
        {
            PyObject* val_str = PyObject_Str(val);
            err_msg += ": ";
            err_msg += PyUnicode_AsUTF8(val_str);
            Py_XDECREF(val_str);
        }

        Py_XDECREF(exc);
        Py_XDECREF(val);
        Py_XDECREF(tb);

        Swig::DirectorMethodException::raise(err_msg.c_str());
    }
}

%typemap(out) char[ANY], char[] {
    if ($1) {
        iconv_t conv = iconv_open("UTF-8", "GBK");
        if (conv == (iconv_t)-1) {
            PyErr_SetString(PyExc_RuntimeError, "Failed to initialize iconv.");
            SWIG_fail;
        } else {
            size_t inlen = strlen($1);
            size_t outlen = inlen * 2;
            char buf[outlen] = {};
            char **in = &$1;
            char *out = buf;

            if (iconv(conv, in, &inlen, &out, &outlen) != (size_t)-1) {
                iconv_close(conv);
                $result = SWIG_FromCharPtrAndSize(buf, sizeof buf - outlen);
            } else {
                iconv_close(conv);
                PyErr_SetString(PyExc_UnicodeError, "Error converting from GBK to UTF-8.");
                SWIG_fail;
            }
        }
    }
}

%typemap(in) (char **ARRAY, int SIZE) {
    if (PyList_Check($input)) {
        int i = 0;
        $2 = PyList_Size($input);
        $1 = (char **)malloc(($2+1)*sizeof(char *));
        for (; i < $2; i++) {
            PyObject *o = PyList_GetItem($input,i);
            if (PyString_Check(o))
                $1[i] = PyString_AsString(PyList_GetItem($input,i));
            else {
                PyErr_SetString(PyExc_TypeError,"list must contain strings");
                free($1);
                return NULL;
            }
        }
        $1[i] = 0;
    } else {
        PyErr_SetString(PyExc_TypeError, "not a list");
        return NULL;
    }
}

%typemap(freearg) (char **ARRAY, int SIZE) {
    free((char *)$1);
}

%apply (char **ARRAY, int SIZE) { (char *ppInstrumentID[], int nCount) };

%feature("director") CThostFtdcMdSpi;
%feature("director") CThostFtdcTraderSpi;

%include "ThostFtdcUserApiDataType.h"
%include "ThostFtdcUserApiStruct.h"
%include "ThostFtdcMdApi.h"
%include "ThostFtdcTraderApi.h"
