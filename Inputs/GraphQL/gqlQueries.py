getAHUStatusInGroupGRP00= """query getAHUStatusInGroupGRP00 {
            site {
                groups : children(selector:{type: Group,oid:17}) {
                    oid type displayName
                    ahus: children(selector:{type: AHU}) {
                        oid type displayName name
                        controls: search(selector: {target: CONTROL}, pruneDepth: false){
                            oid type displayName name
                              status:targetStatus(target: CONTROL) {origin}
                        }
                    }
                }
            }
        }
"""
getCtrlStateValue= """query getCtrlStateValue
{
  site {
    groups: children(selector:{type: Group, name: "GRP00"}) {
      children(selector:{type: GroupStatus, name: "Group Status"}){
        children(selector:{type: State, name: "CtrlState"}){
          name pointCurrent{
            value }
        }
      }
    }
  }
}
"""

rackSensorPoints= """query rackSensorPoints {
            site {
              groups: children(selector: {type: Group,name: "GRP00"}) @skip(if:false) {
                oid name
               racks: children(selector:{type: Rack},){

                  oid
                  displayName
              points: children{
                oid
                name
                  type
                pointCurrent{
                  value
                }

              }

              }
              }
              }
            }
"""
pointWrite= """mutation pointWrite {
  pointWrite(requests: [{oid: 26279, value: 66.6}]) {
    index
    reason
  }
}
"""

parameterization= """mutation configWrite { configSet(requests: [{module: "${module_name}", name: "${field_name}", value: "${value}"}]) { index reason }}
"""