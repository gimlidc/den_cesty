select name, surname, prumery.dist from
  (SELECT walker_id, avg(distance) as dist
   FROM (SELECT *, rank() OVER (PARTITION BY walker_id ORDER BY distance DESC)
            FROM
              (select * from results where walker_id in
                            (select walker_id from results
                            group by walker_id
                            having count(*)>6)
              order by walker_id) as results12
        ) as foo
  WHERE rank < 7 and rank >1
group by walker_id) as prumery,walkers where prumery.walker_id=walkers.id
order by dist desc;
