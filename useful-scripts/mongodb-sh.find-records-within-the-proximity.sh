[
  {
    $lookup: {
      from: "records",
      let: { loc: "$location", currentId: "$_id" },
      pipeline: [
        {
          $geoNear: {
            near: "$$loc",
            distanceField: "distance",
            maxDistance: 250,
            spherical: true,
            query: { $expr: { $ne: ["$_id", "$$currentId"] } }
          }
        },
        {
          $project: {
            _id: 1,
            code: 1,
            name: 1,
            location: 1,
            distance: 1
          }
        }
      ],
      as: "nearbyRecords"
    }
  },
  {
    $match: { "nearbyRecords.0": { $exists: true } }
  },
  {
    $project: {
      _id: 1,
      code: 1,
      name: 1,
      location: 1,
      nearbyRecords: 1
    }
  }
]
