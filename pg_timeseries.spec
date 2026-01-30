%global sname timeseries
%global pginstdir /usr/pgsql-%{pgmajorversion}
%global debug_package %{nil}

Summary:    Simple timeseries tables for PostgreSQL
Name:       pg_%{sname}_%{pgmajorversion}
Version:    %{pgtsversion}
Release:    1%{?dist}
License:    PostgreSQL
URL:        https://github.com/ChuckHend/pg_%{sname}/
Source0:    https://github.com/ChuckHend/pg_%{sname}/archive/refs/tags/v%{version}.tar.gz
BuildRequires:  postgresql%{pgmajorversion}-devel
BuildArch: noarch
Requires:   postgresql%{pgmajorversion}-server
Requires:   pg_partman_%{pgmajorversion}
Requires:   pg_cron_%{pgmajorversion}

%description
Provides a cohesive user experience around the creation, maintenance,
and use of time-series tables.

%prep
%setup -q -n pg_%{sname}-%{version}

%build
USE_PGXS=1 PATH=%{pginstdir}/bin:$PATH %{__make} %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
USE_PGXS=1 PATH=%{pginstdir}/bin:$PATH %{__make} %{?_smp_mflags} INSTALL_PREFIX=%{buildroot} DESTDIR=%{buildroot} install

%files
%defattr(-,root,root,-)
%{pginstdir}/share/extension/%{sname}*.sql
%{pginstdir}/share/extension/%{sname}.control
%{pginstdir}/doc/extension/guide.md
%{pginstdir}/doc/extension/reference.md
%{pginstdir}/doc/extension/timeseries.md
