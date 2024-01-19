
DATE=$(date +'%Y%m%d_%H%M%S')
REPORTDIR="profiles"
mkdir -p "${REPORTDIR}"
FILEPREFIX="${REPORTDIR}/profile-${DATE}"
export PPROF_TMPDIR="$(mktemp -d /tmp/pprof-XXXXXX)"
echo "Traces in '${PPROF_TMPDIR}'"

echo "=======================================" >> "${REPORTDIR}/report.txt"
echo "${DATE}" >> "${REPORTDIR}/report.txt"
./alertmanager --version >> "${REPORTDIR}/report.txt"
go tool pprof -raw http://localhost:9093/debug/pprof/allocs > /dev/null
mv "${PPROF_TMPDIR}/pprof.alertmanager.alloc_objects.alloc_space.inuse_objects.inuse_space.001.pb.gz" "${FILEPREFIX}.pb.gz"
go tool pprof -sample_index=alloc_objects -text "${FILEPREFIX}.pb.gz" | grep "^Showing" >> "${REPORTDIR}/report.txt"
go tool pprof -sample_index=alloc_space -text "${FILEPREFIX}.pb.gz" | grep "^Showing" >> "${REPORTDIR}/report.txt"
go tool pprof -sample_index=inuse_objects -text "${FILEPREFIX}.pb.gz" | grep "^Showing" >> "${REPORTDIR}/report.txt"
go tool pprof -sample_index=inuse_space -text "${FILEPREFIX}.pb.gz" | grep "^Showing" >> "${REPORTDIR}/report.txt"

rmdir "${PPROF_TMPDIR}"
